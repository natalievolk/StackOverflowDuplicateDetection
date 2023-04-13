# Detecting Duplicate Questions on Stack Overflow Using Source Code

Willis Guo, Natalie Volk, and Qingyuan Wu

### 1.0 Introduction
Duplicate questions are problematic on Community Question Answering (CQA) programming platforms like Stack Overflow, as they reduce the quality of the site's content. Current processes for duplicate post removal rely on users and moderators manually flagging the duplicate questions; however, this is inefficient and can only be done retroactively. 

With 23 million questions on Stack Overflow as of January 2023, almost 1.4 million of which have been marked as duplicate [1], the current process of manually flagging questions can be time consuming and unreliable. Creating an accurate duplicate question detection model will allow duplicate answers to be flagged immediately, or could even warn users against posting the duplicate questions in the first place. This could greatly reduce the bloat of Stack Overflow and transform Stack Overflow into a more usable repository of answers.

Stack Overflow posts are unique from other CQA platforms due to the presence of code snippets in nearly all posts. Our project tries to make use of this by creating a bimodal Natural Language / Programming Language (NL-PL) model to detect duplicates. Our project seeks to combine two prominent papers related to this topic: beginning with the pre-trained model from the 2022 MQDD paper, we are finetuning our model with the triplet loss function introduced by the 2019 Sentence-BERT paper [1][2]. For the finetuning process, we have created our dataset by querying the Stack Overflow Data Dump [3]. Our dataset can be found at [4] and our GitHub  repository can be found at [5]. 

### 2.0  Prior Work

Code block: 
```python
def f(a, b): return a + b
```

### 3.0  Data Collection & Processing
#### 3.1  Work Accomplished
We have designed SQL queries to collect data from the Stack Overflow Data Dump [3] and processed them into CSV files that can be found in our Google Drive folder: [4].

We have tried three separate approaches to loading and querying the Stack Overflow Data Dump **FINISH THIS WITH REFERENCES**

From the Stack Overflow Data Dump, we used two relevant tables: *Posts*, which stores all questions and answers postings on Stack Overflow, and *PostLinks*, which includes information on posts that are marked as duplicates. We designed queries to find both positive and negative examples (see Figure XXX). In order to deal with limited compute power, we had to extensively re-optimize our queries to run within our constraints. From each post, we stored the unique post id, title, body, and tags.

```
WITH DuplicatePosts AS (
  SELECT PostId, RelatedPostId AS PostIdOfDuplicate 
  FROM PostLinks WHERE LinkTypeId = 3
)

SELECT
  P1.Id AS Id1, P1.Title AS Title1, P1.Body AS Body1,
  P2.Id AS Id2, P2.Title AS Title2, P2.Body AS Body2, 
  P1.Tags AS Tags1, P2.Tags AS Tags2
FROM Posts P1, Posts P2, DuplicatePosts
WHERE P1.Id = DuplicatePosts.PostId 
  AND P2.Id = DuplicatePosts.PostIdOfDuplicate
  AND ((
      P1.Tags LIKE '%<javascript>%' OR
      P1.Tags LIKE '%<java>%' OR
      P1.Tags LIKE '%<c#>%' OR
      P1.Tags LIKE '%<php>%' OR
      P1.Tags LIKE '%<python>%'
    ) AND (
      P2.Tags LIKE '%<javascript>%' OR
      P2.Tags LIKE '%<java>%' OR
      P2.Tags LIKE '%<c#>%' OR
      P2.Tags LIKE '%<php>%' OR
      P2.Tags LIKE '%<python>%'
    )
  );
```
***Figure XXX:** the SQL query to select duplicate (positive) posts. The Posts and PostLinks tables were used to identify which posts have been verified as duplicates. Duplicate posts are then limited by programming language, where only hte top five most popular ones are kept. Our other SQL queries can be found on our GitHub: [https://github.com/natalievolk/StackOverflowDuplicateDetection/tree/main/queries](https://github.com/natalievolk/StackOverflowDuplicateDetection/tree/main/queries).*

Our next step in creating our dataset was data processing. The three main modifications that we had to make to the bodies of each post were:
- Remove any indicators of this is a duplicate post
- Remove all HTML tags
- Separate code from natural language texts

We processed the code using the Python library, BeautifulSoup. See Figure YYY for a code snippet outlining the process.

```python
def separate_code_text(body1, body2, body3=None):
  '''
  - removes any indicators of duplicate posts (ie, blockquote with duplicate message)
  - separates code from text
  - removes all html tags

  returns: text, code for each of the body inputs
  '''

  soup = BeautifulSoup(body1, "html.parser")

  blockquotes = soup.find_all("blockquote")

  # remove the duplicate blockquote elements and its contents
  for bq in blockquotes:
    if "Duplicate" in bq:
      bq.decompose()
      break

  # separate code blocks
  code_blocks = soup.find_all("code")
  code = []
  for cb in code_blocks:
      code.append(cb.get_text())
      cb.decompose()

  # separate natural language from code elements
  text1 = soup.get_text()
  code1 = "\n".join(code)

'''code is continued... see GitHub for full implementation'''

    return pd.Series({"BodyText1": text1, "BodyCode1": code1, "BodyText2": text2, "BodyCode2": code2, "BodyText3": text3, "BodyCode3": code3})
```
***Figure YYY:** The above function takes in 2-3 bodies, depending on whether we're processing the data for training the triplet loss or the classifier head. Then, we remove any duplicate blockquotes, remove all HTML tags, and separate text from code blocks. Full code can be found on our GitHub: [https://github.com/natalievolk/StackOverflowDuplicateDetection](https://github.com/natalievolk/StackOverflowDuplicateDetection).*

After processing our data, the duplicate and non-duplicate pairs of posts had to be combined for training. Because our training process contains two components, we had to create two separate datasets. The first dataset is for training the triplet loss. It contains 50,000 triplets of posts. The first post in the triplet is the anchor; the second post is the duplicate (positive example); and the third post is the randomly-selected non-duplicate (negative example). The second dataset is for training the classifier head. It contains another 100,000 pairs of posts, along with a label of whether the posts are duplicates or non-duplicates. Our completed datasets can be found at [4].

We are currently working on improving heuristics for pairing non-duplicate posts. Currently, we randomly select pairs of posts and then ensure that they are non-duplicates. However, we would also like to have a sets of data that pairs posts that are similar, but not duplicates. Thus, we would want to have 5 labels for our data, as shown below. The positive and negative signs indicate whether these pairings would be considered a positive or negative example. 
- Duplicate (+)
- Random non-duplicate (-)
- Similar tags non-duplicate (-)
- Similar text non-duplicate (-)
- Similar code non-duplicate (-)

We have already created a heuristic for matching posts based on whether they share at least 50% of the same tags. The code can be found in Figure ZZZ.

```python
def tag_similarity(tags1, tags2):
  '''
  tags1, tags2 -> both are strings formatted like "<tagA><tagB><etc>"
  '''
  # return 0% similarity if one of the tags values are null
  if not tags1 or not tags2:
    return 0
  
  # remove opening + closing < >
  tags1, tags2 = tags1[1:-1], tags2[1:-1]

  set1 = set(tags1.split("><"))
  set2 = set(tags2.split("><"))

  sim1, sim2 = len(set1 & set2)/len(set2), len(set1 & set2)/len(set1)

  return pd.Series({"Similarity1": sim1, "Similarity2": sim2})


THRESHOLD = 0.5
df_similar_tags = df[(df['TagSimilarity1'] > THRESHOLD) \
                     & (df['TagSimilarity2'] > THRESHOLD)]
```
***Figure ZZZ:** The above function takes in two sets of tags (one for each of the posts in the pair) and filters out any pairs that have fewer than 50% of the same tags.*

Potential heuristics for matching non-duplicate posts based on code and text similarity can be found in Section 3.4.

#### 3.2  Challenges
We have faced major computational limitations in data collection, due to the massive size of the dataset. We have already attempted two approaches for data collection: using the online Stack Overflow Data Explorer to query the database virtually, and downloading and querying the database locally.

When using the online Stack Overflow Data Explorer, there are two main limitations. First of all, queries time out after about one minute, making complex queries on the 58 million rows in the Posts table impossible. Secondly, even when a query completes, the Data Explorer limits outputs to 50,000 rows. Since we were hoping to build a massive corpus for our custom dataset, this is not what we envisioned.

For our second approach, we downloaded the archive file, converted to XML, and loading the XML data to a local SQLite database. Unfortunately, we have found that the computational power of our laptops is also insufficient for the vast size of the dataset. Downloading and converting the file took a few hours, and inserting all the rows into our local SQLite took over 8 hours. We have done much trial-and-error to optimize our queries to run in a reasonable amount of time, but even so, we have to significantly limit the size of our output dataset. 


#### 3.3  Potential Solutions
We have a few potential solutions in order to overcome these challenges:
- **Use a more efficient DBMS:**  We initially chose SQLite as it is free, no matter the size of the database. However, its queries are significantly less efficient than other DBMS. We could switch to using MS SQL Server, which is much more efficient; however, we would have to purchase a subscription since our database is larger than 10 GB.
- **Limit our data:** Currently, our data includes the top five most popular coding languages on Stack Overflow, which is nearly 25 million posts [3]. We could use the tags of the posts to limit this further to only one coding language, or even subtopics within a coding language (eg, posts about a specific Python library, like BeautifulSoup).


#### 3.4  Future Steps




### 6.0	References
[1]  J. Pasek, J. Sido, et al., “MQDD: Pre-training of Multimodal Question Duplicity Detection for Software Engineering Domain,” 2022. Available: https://arxiv.org/abs/2203.14093.
[2]  N. Reimers and I. Gurevych, “Sentence-BERT: Sentence Embeddings using Siamese BERT-Networks,”, EMNLP, 2019. Available: https://arxiv.org/abs/1908.10084.
[3]  2023, “Stack Overflow Data Explorer,” StackExchange Data Explorer. [Online]. Available: https://data.stackexchange.com/.
[4] https://drive.google.com/drive/folders/1vXfV9NErpZDnzNIxkOKePa_vomN1_auk?usp=share_link
[5] https://github.com/natalievolk/StackOverflowDuplicateDetection

[A] 
