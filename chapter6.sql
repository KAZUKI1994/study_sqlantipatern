/*
	初期テーブル作成
*/

create table Bugs(
	bug_id SERIAL PRIMARY KEY,
	issue_id BIGINT NOT NULL,
	content TEXT
);

create table FeatureRequests(
	feature_request_id SERIAL PRIMARY KEY,
	issue_id BIGINT NOT NULL,
	content TEXT
);

create table Comments(
	comment_id SERIAL PRIMARY KEY,
	issue_type VARCHAR(20),
	issue_id BIGINT NOT NULL,
	author BIGINT NOT NULL,
	comment_date DATETIME,
	comment TEXT
);

create table BugsComments(
	issue_id BIGINT NOT NULL,
	comment_id BIGINT NOT NULL,
	PRIMARY KEY (issue_id, comment_id),
	FOREIGN KEY (issue_id) REFERENCES Bugs(issue_id),
	FOREIGN KEY (comment_id) REFERENCES Comments(comment_id)
);

create table FeaturesComments(
	issue_id BIGINT NOT NULL,
	comment_id BIGINT NOT NULL,
	PRIMARY KEY (issue_id, comment_id),
	FOREIGN KEY (issue_id) REFERENCES Bugs(issue_id),
	FOREIGN KEY (comment_id) REFERENCES Comments(comment_id)
);

/*
	テストデータ作成
*/

INSERT INTO Bugs(
	bug_id,
	issue_id,
	content)
VALUES(
	1,
	1,
	"至急！本日１件目のバグです。"
),(
	2,
	3,
	"本日２つ目のバグ！機能追加と重複することが期待値"
);

INSERT INTO FeatureRequests(
	feature_request_id,
	issue_id,
	content)
VALUES(
	1,
	2,
	"本日１件目の機能追加です。"
),(
	2,
	3,
	"本日２つ目の機能追加！バグと重複することが期待値"
);

INSERT INTO Comments(
	comment_id,
	issue_id,
	comment_date,
	comment
)
VALUES(
	1,
	1,
	now(),
	"このバグの再現はこちらで確認できませんので対応保留とさせていただきます。"
),(
	2,
	2,
	now(),
	"この機能追加は特段必要性が感じないので対応保留とさせていただきます。"
),(
	3,
	3,
	now(),
	"機能追加にもバグにも紐付けれちゃうよ。これってどうよ？"
);

INSERT INTO BugsComments(
	issue_id,
	comment_id
)
VALUES(
	1,
	1
),(
	3,
	3
);

INSERT INTO FeaturesComments(
	issue_id,
	comment_id)
VALUES(
	2,
	2
),(
	3,
	3
);

/*
	試しに検索してみる
*/
select
 b.issue_id, b.content, c.comment_id, c.comment, c.comment_date
from Bugs b 
JOIN BugsComments bc ON b.issue_id = bc.issue_id
JOIN Comments c ON bc.comment_id = c.comment_id
WHERE b.issue_id = 3\G

select
 fr.issue_id, fr.content, c.comment_id, c.comment, c.comment_date
from FeatureRequests fr 
JOIN FeaturesComments fc ON fr.issue_id = fc.issue_id
JOIN Comments c ON fc.comment_id = c.comment_id
WHERE fr.issue_id = 3\G

/*
	複数テーブルをあたかも一テーブルかのように検索する
*/
select
	b.issue_id, b.content
from Comments c
inner join (
	BugsComments inner join Bugs b
		using(issue_id)
	) using(comment_id)
where c.comment_id = 2
union
select fr.issue_id, fr.content
from Comments c
inner join(
	FeaturesComments fc inner join FeatureRequests fr
		using(issue_id)	
	)using(comment_id)
where c.comment_id = 2;


select c.*,
	COALESCE(b.issue_id, fr.issue_id) AS issue_id,
	COALESCE(b.content, fr.content) AS content
from Comments c
left join(
	BugsComments inner join Bugs b
		using(issue_id)
)using(comment_id)
left join(
	FeaturesComments inner join FeatureRequests fr
		using(issue_id)
)using(comment_id)
where c.comment_id = 1;



/* クエリ例1 */
select *
from Comments c
left join Bugs b using(issue_id)
left join FeatureRequests fr using(issue_id)
where Comment_id = 1;

/* クエリ例2　*/
select *
from Bugs b
join Comments c using(issue_id)
where b.issue_id;
