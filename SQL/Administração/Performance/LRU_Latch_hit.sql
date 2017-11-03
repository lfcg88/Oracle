SELECT l.name, sleeps,gets,sleeps/gets "LRU Hits%"
      FROM v$latch l, v$latchname ln
      WHERE ln.name IN ('cache buffers lru chain')
        AND ln.latch# = l.latch#;
