-- pairs of duplicates posts, with all languages

WITH DuplicatePosts AS (
  SELECT PostId, RelatedPostId AS PostIdOfDuplicate 
  FROM PostLinks WHERE LinkTypeId = 3
)

SELECT
  P1.Id AS Id1, P1.Title AS Title1, P1.Body AS Body1, 
  P2.Id AS Id2, P2.Title AS Title2, P2.Body AS Body2
FROM Posts P1, Posts P2, DuplicatePosts
WHERE P1.Id = DuplicatePosts.PostId 
  AND P2.Id = DuplicatePosts.PostIdOfDuplicate;
