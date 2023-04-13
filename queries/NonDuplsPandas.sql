-- get all posts not present in the duplicates table
CREATE TABLE #DuplicatePostIds (
  Id int
);

INSERT INTO #DuplicatePostIds (Id)
(
    SELECT PostId AS Id
    FROM PostLinks WHERE LinkTypeId = 3
    UNION
    SELECT RelatedPostId AS PostId
    FROM PostLinks WHERE LinkTypeId = 3
);

SELECT Id, Title, Body, Tags
FROM Posts
WHERE Tags LIKE '%<python>%' AND
      Tags LIKE '%<pandas>%' AND 
      Id NOT IN (SELECT * FROM #DuplicatePostIds);