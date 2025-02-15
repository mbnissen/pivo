defmodule Pivo.Repo.Migrations.AddPhoenixAnalytics do
  use Ecto.Migration

  @requests "requests"

  def up do
    query = """
    CREATE TABLE IF NOT EXISTS #{@requests} (
      request_id UUID PRIMARY KEY,
      method VARCHAR NOT NULL,
      path VARCHAR NOT NULL,
      status_code SMALLINT NOT NULL,
      duration_ms INTEGER NOT NULL,
      user_agent VARCHAR,
      remote_ip VARCHAR,
      referer VARCHAR,
      device VARCHAR,
      session_id UUID,
      session_page_views INTEGER,
      inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """

    execute(query)
  end

  def down do
    query = "DROP TABLE IF EXISTS #{@requests};"

    execute(query)
  end
end
