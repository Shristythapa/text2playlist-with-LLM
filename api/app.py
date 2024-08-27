
from flask import Flask, request, jsonify
from transformers import T5Tokenizer, T5ForConditionalGeneration
from sqlalchemy import create_engine, text
import os
from word2number import w2n
import random

app = Flask(__name__)
os.environ['FLASK_ENV'] = 'development'
model_path = './checkpoint-2500'
model = T5ForConditionalGeneration.from_pretrained(model_path)
tokenizer = T5Tokenizer.from_pretrained('t5-base')
feature_names = [
    "danceability", "energy", "key", "loudness", "mode", 
    "speechiness", "acousticness", "instrumentalness", 
    "liveness", "valence", "tempo"
]

db_string = 'postgresql://postgres:postpass@localhost:5432/Playlist_Create_App'
engine = create_engine(db_string)

from flask import  Flask, request
import os

app = Flask(__name__)


def parse_generated_features(feature_names, generated_music_features):
    print(generated_music_features)
    
    words = generated_music_features.split()
    result = {}
    current_key = None
    current_value = []

    for word in words:
        if word.endswith(':'):
            if current_key:

                number_str = ' '.join(current_value)
                try:
                    result[current_key] = w2n.word_to_num(number_str)
                except ValueError:
                    result[current_key] = number_str
        
            current_key = word[:-1]
            current_value = []
        else:
            current_value.append(word)
    
    if current_key:
        number_str = ' '.join(current_value)
        try:
            result[current_key] = w2n.word_to_num(number_str)
        except ValueError:
            result[current_key] = number_str

    print(result)    
    return result

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    playlist_description = data.get('description', '')
    # access_token = data.get('access_token', '')
    # print(f'access token {access_token}')
    print(f'description {playlist_description}')
    prompt = f"{playlist_description}"

    inputs = tokenizer(prompt, return_tensors="pt")

    outputs = model.generate(input_ids=inputs['input_ids'],
                             attention_mask=inputs['attention_mask'],
                             max_length=100,
                             num_beams=5,
                             early_stopping=True)

    generated_music_features = tokenizer.decode(outputs[0], skip_special_tokens=True)

    try:
        formatted_features = parse_generated_features(feature_names, generated_music_features)
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

    random_factor = random.uniform(-0.05, 0.05)

    query = text(f"""
    WITH normalized_features AS (
        SELECT
            uri,
            (danceability - MIN(danceability) OVER()) / (MAX(danceability) OVER() - MIN(danceability) OVER()) AS norm_danceability,
            (energy - MIN(energy) OVER()) / (MAX(energy) OVER() - MIN(energy) OVER()) AS norm_energy,
            (key - MIN(key) OVER()) / (MAX(key) OVER() - MIN(key) OVER()) AS norm_key,
            (mode - MIN(mode) OVER()) / (MAX(mode) OVER() - MIN(mode) OVER()) AS norm_mode,
            (speechiness - MIN(speechiness) OVER()) / (MAX(speechiness) OVER() - MIN(speechiness) OVER()) AS norm_speechiness,
            (acousticness - MIN(acousticness) OVER()) / (MAX(acousticness) OVER() - MIN(acousticness) OVER()) AS norm_acousticness,
            (instrumentalness - MIN(instrumentalness) OVER()) / (MAX(instrumentalness) OVER() - MIN(instrumentalness) OVER()) AS norm_instrumentalness,
            (liveness - MIN(liveness) OVER()) / (MAX(liveness) OVER() - MIN(liveness) OVER()) AS norm_liveness
        FROM
            "popular songs"
    ),
    distances AS (
        SELECT
            uri,
            SQRT(POWER(norm_danceability + {random_factor} - :danceability, 2) +
                 POWER(norm_energy + {random_factor} - :energy, 2) +
                 POWER(norm_key + {random_factor} - :key, 2) +
                 POWER(norm_mode + {random_factor} - :mode, 2) +
                 POWER(norm_speechiness + {random_factor} - :speechiness, 2) +
                 POWER(norm_acousticness + {random_factor} - :acousticness, 2) +
                 POWER(norm_instrumentalness + {random_factor} - :instrumentalness, 2) +
                 POWER(norm_liveness + {random_factor} - :liveness, 2)) AS distance
        FROM normalized_features
    )
    SELECT uri
    FROM distances
    ORDER BY distance
    LIMIT 10;
""")

    with engine.connect() as connection:
        result = connection.execute(query, formatted_features)  

        similar_tracks = [row[0] for row in result]
    return similar_tracks


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
