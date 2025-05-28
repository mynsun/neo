import openai
import requests
from IPython.display import Image, display

org_img_file = './data/org_image_for_edit.png'
mask_img_file = './data/mask_image_for_edit.png'


with open(org_img_file, "rb") as image, open(mask_img_file, "rb") as mask:
    response = requests.post(
        "https://api.openai.com/v1/images/edits",
        headers={
            "Authorization": f"Bearer {openai.api_key}"
        },
        files={
            "image": ("org_img_file.png", image, "image/png"),
            "mask": ("mask_img_file.png", mask, "image/png")
        },
        data={
            "prompt": "Happy robots swimming in the water",
            "n": 1,
            "size": "512x512"
        }
    )

result = response.json()
print(result["data"][0]["url"])