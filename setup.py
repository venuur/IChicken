from setuptools import setup

with open('README.md', 'r') as readme:
    long_description = readme.read()

setup(
    name='IChicken',
    version='0.0',
    packages=['ichicken'],
    url='https://github.com/venuur/IChicken',
    license='MIT',
    author='Carl Morris',
    author_email='carl.morris.world@outlook.com',
    description='Chicken Scheme kernel for Jupyter.',
    long_description=long_description,
    long_description_content_type='text/markdown',
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent'
    ]
)
