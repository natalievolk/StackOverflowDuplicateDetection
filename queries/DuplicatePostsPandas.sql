WITH DuplicatePosts AS (
  SELECT PostId, RelatedPostId AS PostIdOfDuplicate 
  FROM PostLinks WHERE LinkTypeId = 3
)

-- all duplicate pairs of posts
SELECT
  P1.Id AS Id1, P1.Title AS Title1, P1.Body AS Body1,
  P2.Id AS Id2, P2.Title AS Title2, P2.Body AS Body2, 
  P1.Tags AS Tags1, P2.Tags AS Tags2
FROM Posts P1, Posts P2, DuplicatePosts
WHERE P1.Id = DuplicatePosts.PostId 
  AND P2.Id = DuplicatePosts.PostIdOfDuplicate
  AND ((
      P1.Tags LIKE '%<python>%' AND
      P1.Tags LIKE '%<pandas>%'
    )
    AND (
      P2.Tags LIKE '%<python>%' AND
      P2.Tags LIKE '%<pandas>%'
    )
  );

  