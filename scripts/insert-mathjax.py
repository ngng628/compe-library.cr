import os
from bs4 import BeautifulSoup

# HTMLファイルをリストアップ
html_files = []
for root, dirs, files in os.walk('dist/api/'):
   for file in files:
      if file.endswith(".html"):
         html_files.append(os.path.join(root, file))

mathjax = """
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
<script type="text/javascript">
MathJax = {
  tex: {
    inlineMath: [['$', '$']]
  },
  svg: {
    fontCache: 'global'
  }
};
</script>
"""

for name in html_files:
   with open(name, 'r') as file:
      html = file.read()

   soup = BeautifulSoup(html, 'html.parser')
   head_tag = soup.find('head')
   if head_tag:
      head_tag.append(BeautifulSoup(mathjax, 'html.parser'))

   modified_html = soup.prettify()

   with open(name, 'w') as file:
      file.write(modified_html)

