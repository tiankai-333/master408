import fitz
import os
import base64
from pathlib import Path

pdf_path = r"c:/Dev/Workspaces/master408/sql/2024年408计算机专业基础综合真题+答案.pdf"
output_dir = r"c:/Dev/Workspaces/master408/docs/05-data-pipeline/2024_408"
img_dir = os.path.join(output_dir, "images")

os.makedirs(output_dir, exist_ok=True)
os.makedirs(img_dir, exist_ok=True)

doc = fitz.open(pdf_path)

md_content = []
md_content.append("# 2024年408计算机专业基础综合真题\n")
md_content.append("> 来源: 2024年408计算机专业基础综合真题+答案.pdf\n\n")

image_refs = []

for page_num in range(len(doc)):
    page = doc[page_num]
    text = page.get_text("text")

    md_content.append(f"## 第{page_num + 1}页\n\n")
    md_content.append(text)
    md_content.append("\n\n---\n\n")

    image_list = page.get_images(full=True)
    for img_index, img in enumerate(image_list):
        xref = img[0]
        base_image = doc.extract_image(xref)
        image_bytes = base_image["image"]
        image_ext = base_image["ext"]

        image_filename = f"page{page_num + 1}_img{img_index + 1}.{image_ext}"
        image_path = os.path.join(img_dir, image_filename)

        with open(image_path, "wb") as f:
            f.write(image_bytes)

        img_b64 = base64.b64encode(image_bytes).decode('utf-8')
        image_refs.append({
            "filename": image_filename,
            "page": page_num + 1,
            "index": img_index + 1,
            "base64": img_b64,
            "md_reference": f"![图-{page_num + 1}-{img_index + 1}](images/{image_filename})"
        })

        md_content.append(f"![图-{page_num + 1}-{img_index + 1}](images/{image_filename})\n\n")

md_path = os.path.join(output_dir, "2024_408_真题.md")
with open(md_path, "w", encoding="utf-8") as f:
    f.writelines(md_content)

ref_path = os.path.join(output_dir, "image_references.md")
with open(ref_path, "w", encoding="utf-8") as f:
    f.write("# 图片索引\n\n")
    f.write("| 页码 | 序号 | 文件名 | Base64 (用于代码导入) |\n")
    f.write("|------|------|--------|----------------------|\n")
    for ref in image_refs:
        f.write(f"| {ref['page']} | {ref['index']} | {ref['filename']} | `{ref['base64'][:50]}...` |\n")

print(f"PDF转换为Markdown完成！")
print(f"输出目录: {output_dir}")
print(f"总页数: {len(doc)}")
print(f"图片数量: {len(image_refs)}")
print(f"\n主要文件:")
print(f"  - {md_path}")
print(f"  - {ref_path}")
