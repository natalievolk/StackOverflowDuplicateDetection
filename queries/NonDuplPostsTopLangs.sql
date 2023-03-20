-- returns all non duplicate posts from top 5 most common languages

CREATE TABLE #DuplicatePosts1 (
  PostId1 int,
  PostId2 int
);

INSERT INTO #DuplicatePosts1 (PostId1, PostId2)
SELECT PostId AS PostId1, RelatedPostId AS PostId2 
FROM PostLinks WHERE LinkTypeId = 3;


CREATE TABLE #DuplicatePosts2 (
  PostId1 int,
  PostId2 int
);

INSERT INTO #DuplicatePosts2 (PostId1, PostId2)
SELECT RelatedPostId AS PostId1, PostId AS PostId2 
FROM PostLinks WHERE LinkTypeId = 3;


CREATE TABLE #DuplicatePosts (
  PostId1 int,
  PostId2 int
);

INSERT INTO #DuplicatePosts (PostId1, PostId2)
(SELECT PostId1, PostId2
FROM #DuplicatePosts1
  UNION 
SELECT PostId1, PostId2
FROM #DuplicatePosts2);


CREATE TABLE #Top5LanguagePosts (
  PostId int
);

INSERT INTO #Top5LanguagePosts (PostId)
SELECT Id AS PostId
FROM Posts
WHERE (
  Tags LIKE '%<javascript>%' OR
  Tags LIKE '%<java>%' OR
  Tags LIKE '%<c#>%' OR
  Tags LIKE '%<php>%' OR
  Tags LIKE '%<python>%'
);


CREATE TABLE #NonDuplicatePostPairs (
  PostId1 int,
  PostId2 int
);

INSERT INTO #NonDuplicatePostPairs (PostId1, PostId2) (
  SELECT P1.PostId AS PostId1, P2.PostId AS PostId2
  FROM #Top5LanguagePosts P1, #Top5LanguagePosts P2
    EXCEPT 
  SELECT PostId1, PostId2 FROM #DuplicatePosts1
    EXCEPT 
  SELECT PostId1, PostId2 FROM #DuplicatePosts2
);


SELECT TOP 50000 *
FROM 
    (SELECT PostId1, Title, Body, Tags 
     FROM #NonDuplicatePostPairs LEFT JOIN Posts ON PostId1 = Id) Posts1
  CROSS JOIN
    (SELECT PostId2, Title, Body, Tags 
     FROM #NonDuplicatePostPairs LEFT JOIN Posts ON PostId2 = Id) Posts2;