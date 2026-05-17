import easyocr
from PIL import Image
import os

img_dir = r"c:/Dev/Workspaces/master408/docs/05-data-pipeline/2024_408/images"
output_file = r"c:/Dev/Workspaces/master408/docs/05-data-pipeline/2024_408/ocr_text.md"

print("初始化EasyOCR (首次运行会下载模型)...")
reader = easyocr.Reader(['ch_sim', 'en'], gpu=False)

results = []

for i in range(1, 25):
    img_path = os.path.join(img_dir, f"page{i}_img1.jpeg")
    if os.path.exists(img_path):
        print(f"OCR processing page {i}...")
        result = reader.readtext(img_path)
        text_lines = []
        for detection in result:
            text_lines.append(detection[1])
        text = "\n".join(text_lines)
        results.append({
            "page": i,
            "filename": f"page{i}_img1.jpeg",
            "text": text
        })

with open(output_file, "w", encoding="utf-8") as f:
    f.write("# 2024年408真题 OCR识别结果\n\n")
    for r in results:
        f.write(f"## 第{r['page']}页 - {r['filename']}\n\n")
        f.write(r['text'])
        f.write("\n\n---\n\n")

print(f"\nOCR完成！结果已保存到: {output_file}")
