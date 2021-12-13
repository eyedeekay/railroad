package database

const stmtDeletePostTagsByPostId = "DELETE FROM posts_tags WHERE post_id = ?"
const stmtDeletePostById = "DELETE FROM posts WHERE id = ?"

func DeletePostTagsForPostId(post_id int64) error {
	writeDB, err := readDB.Begin(true)
	if err != nil {
		writeDB.Rollback()
		return err
	}
	_, err = writeDB.Exec(stmtDeletePostTagsByPostId, post_id)
	if err != nil {
		writeDB.Rollback()
		return err
	}
	return writeDB.Commit()
}

func DeletePostById(id int64) error {
	writeDB, err := readDB.Begin(true)
	if err != nil {
		writeDB.Rollback()
		return err
	}
	_, err = writeDB.Exec(stmtDeletePostById, id)
	//err = writeDB.Update(func(tx *bolt.Tx) error {
	//	b := tx.Bucket([]byte(BucketSharedVar))
	//	return b.Delete([]byte(n))
	//})
	if err != nil {
		writeDB.Rollback()
		return err
	}
	return writeDB.Commit()
}
