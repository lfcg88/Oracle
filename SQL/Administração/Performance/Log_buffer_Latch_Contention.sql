SELECT ln.name, gets, misses, immediate_gets, immediate_misses
      FROM v$latch l, v$latchname ln
      WHERE ln.name IN ('redo allocation', 'redo copy')
        AND ln.latch# = l.latch#;
