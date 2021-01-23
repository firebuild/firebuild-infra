{
  "annotations": {
    "list": [
      {
        "datasource": "MySQL",
        "enable": true,
        "hide": true,
        "iconColor": "#AAAAAA",
        "limit": 100,
        "name": "commit_details_not_tested",
        "rawQuery": "SELECT\n  timestamp AS time,\n  GROUP_CONCAT(CONCAT(commit_hash, \"\\n\", subject) SEPARATOR '\\n') AS text\nFROM commits\nWHERE NOT EXISTS (SELECT 1 FROM buildtimes WHERE buildtimes.commit_timestamp = commits.timestamp)\nAND $__unixEpochFilter(timestamp)\nGROUP BY timestamp\n",
        "showIn": 0,
        "tags": [],
        "type": "tags"
      },
      {
        "datasource": "MySQL",
        "enable": true,
        "hide": true,
        "iconColor": "#8F3BB8",
        "limit": 100,
        "name": "commit_details_tested",
        "rawQuery": "SELECT\n  timestamp AS time,\n  GROUP_CONCAT(CONCAT(commit_hash, \"\\n\", subject) SEPARATOR '\\n') AS text\nFROM commits\nWHERE EXISTS (SELECT 1 FROM buildtimes WHERE buildtimes.commit_timestamp = commits.timestamp)\nAND $__unixEpochFilter(timestamp)\nGROUP BY timestamp\n",
        "showIn": 0,
        "tags": [],
        "type": "tags"
      },
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "limit": 100,
        "name": "Annotations & Alerts",
        "showIn": 0,
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": 1,
  "links": [],
  "panels": [
{% for separator in separators %}
    {
      "datasource": null,
      "description": "{{ separator.description }}",
      "gridPos": {
        "h": 1,
        "w": 24,
        "x": {{ separator.x }},
        "y": {{ separator.y }}
      },
      "id": {{ 100 + loop.index }},
      "targets": [
        {
          "format": "time_series",
          "group": [],
          "metricColumn": "none",
          "rawQuery": false,
          "rawSql": "SELECT\n  UNIX_TIMESTAMP(<time_column>) as time_sec,\n  <value column> as value,\n  <series name column> as metric\nFROM <table name>\nWHERE $__timeFilter(time_column)\nORDER BY <time_column> ASC\n",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "value"
                ],
                "type": "column"
              }
            ]
          ],
          "timeColumn": "time",
          "where": [
            {
              "name": "$__timeFilter",
              "params": [],
              "type": "macro"
            }
          ]
        }
      ],
      "timeFrom": null,
      "timeShift": null,
      "title": "{{ separator.title }}",
      "transparent": true,
      "type": "mxswat-separator-panel"
    },
{% endfor %}
{% for panel in panels %}
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": null,
      "description": "{{ panel.description }}",
      "fill": 0,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 6,
        "x": {{ panel.x }},
        "y": {{ panel.y }}
      },
      "hiddenSeries": false,
      "id": {{ 200 + loop.index }},
      "legend": {
        "alignAsTable": false,
        "avg": false,
        "current": false,
        "hideEmpty": false,
        "hideZero": false,
        "max": false,
        "min": false,
        "rightSide": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 1,
      "points": true,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "alias": "/-j1/",
          "dashLength": 2,
          "dashes": true,
          "spaceLength": 2
        },
        {
          "alias": "/-j4/",
          "dashLength": 8,
          "dashes": true,
          "spaceLength": 2
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "format": "time_series",
          "group": [
            {
              "params": [
                "1s",
                "none"
              ],
              "type": "time"
            }
          ],
          "metricColumn": "CONCAT(project, \" / \", build_command)",
          "rawQuery": false,
          "rawSql": "SELECT\n  commit_timestamp AS \"time\",\n  CONCAT(project, \" / \", build_command) AS metric,\n  {{ panel.expression }}\nFROM buildtimes\nWHERE\n  $__unixEpochFilter(commit_timestamp) AND\n  exit_status = 0 AND\n  project LIKE '%${project_filter:sqlstring}%' AND\n  build_command LIKE '%${build_command_filter:sqlstring}%'  AND\n  abs({{ panel.value_to_filter }}) >= $value_min  AND\n  abs({{ panel.value_to_filter }}) <= $value_max\nGROUP BY 1,2\nORDER BY commit_timestamp",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "{{ panel.expression }}"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "buildtimes",
          "timeColumn": "commit_timestamp",
          "timeColumnType": "int",
          "where": [
            {
              "name": "$__unixEpochFilter",
              "params": [],
              "type": "macro"
            },
            {
              "datatype": "smallint",
              "name": "",
              "params": [
                "exit_status",
                "=",
                "0"
              ],
              "type": "expression"
            },
            {
              "datatype": "varchar",
              "name": "",
              "params": [
                "project",
                "LIKE",
                "'%${project_filter:sqlstring}%'"
              ],
              "type": "expression"
            },
            {
              "datatype": "varchar",
              "name": "",
              "params": [
                "build_command",
                "LIKE",
                "'%${build_command_filter:sqlstring}%'"
              ],
              "type": "expression"
            },
            {
              "datatype": "float",
              "name": "",
              "params": [
                "abs({{ panel.value_to_filter }})",
                ">=",
                "$value_min"
              ],
              "type": "expression"
            },
            {
              "datatype": "float",
              "name": "",
              "params": [
                "abs({{ panel.value_to_filter }})",
                "<=",
                "$value_max"
              ],
              "type": "expression"
            }
          ]
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [
        {
          "colorMode": "background6",
          "fill": true,
          "fillColor": "rgba(234, 112, 112, 0.12)",
          "line": false,
          "lineColor": "rgba(237, 46, 24, 0.60)",
          "op": "time"
        }
      ],
      "timeShift": null,
      "title": "{{ panel.title }}",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": {% if panel.ylabel %}"{{ panel.ylabel }}"{% else %}null{% endif %},
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
{% endfor %}
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": null,
      "description": "Projects that failed to build. Exit status on the y axis (timeout=124, signal=128+signum).",
      "fill": 0,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 0,
        "y": 67
      },
      "hiddenSeries": false,
      "id": 2,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 1,
      "points": true,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "format": "time_series",
          "group": [],
          "metricColumn": "CONCAT(project, \" / \", build_command)",
          "rawQuery": false,
          "rawSql": "SELECT\n  commit_timestamp AS \"time\",\n  CONCAT(project, \" / \", build_command) AS metric,\n  exit_status\nFROM buildtimes\nWHERE\n  $__unixEpochFilter(commit_timestamp) AND\n  exit_status != 0 AND\n  project LIKE '%${project_filter:sqlstring}%' AND\n  build_command LIKE '%${build_command_filter:sqlstring}%'\nORDER BY commit_timestamp",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "exit_status"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "buildtimes",
          "timeColumn": "commit_timestamp",
          "timeColumnType": "int",
          "where": [
            {
              "name": "$__unixEpochFilter",
              "params": [],
              "type": "macro"
            },
            {
              "datatype": "smallint",
              "name": "",
              "params": [
                "exit_status",
                "!=",
                "0"
              ],
              "type": "expression"
            },
            {
              "datatype": "varchar",
              "name": "",
              "params": [
                "project",
                "LIKE",
                "'%${project_filter:sqlstring}%'"
              ],
              "type": "expression"
            },
            {
              "datatype": "varchar",
              "name": "",
              "params": [
                "build_command",
                "LIKE",
                "'%${build_command_filter:sqlstring}%'"
              ],
              "type": "expression"
            }
          ]
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "⚠ failed to build ⚠",
      "tooltip": {
        "shared": true,
        "sort": 0,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": "exit status",
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": null,
      "description": "Cache size growth ratio between the first and second firebuild compilation. The lower the better (higher cache hit rate).",
      "fill": 0,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 12,
        "y": 67
      },
      "hiddenSeries": false,
      "id": 3,
      "legend": {
        "avg": false,
        "current": false,
        "max": false,
        "min": false,
        "show": true,
        "total": false,
        "values": false
      },
      "lines": true,
      "linewidth": 1,
      "nullPointMode": "null",
      "options": {
        "dataLinks": []
      },
      "percentage": false,
      "pointradius": 1,
      "points": true,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "format": "time_series",
          "group": [
            {
              "params": [
                "1s",
                "none"
              ],
              "type": "time"
            }
          ],
          "metricColumn": "CONCAT(project, \" / \", build_command)",
          "rawQuery": false,
          "rawSql": "SELECT\n  commit_timestamp AS \"time\",\n  CONCAT(project, \" / \", build_command) AS metric,\n  $aggr(cachesize2) / $aggr(cachesize1)\nFROM buildtimes\nWHERE\n  $__unixEpochFilter(commit_timestamp) AND\n  exit_status = 0 AND\n  project LIKE '%${project_filter:sqlstring}%' AND\n  build_command LIKE '%${build_command_filter:sqlstring}%' AND\n  cachesize2 / cachesize1 >= $value_minAND\n  cachesize2 / cachesize1 <= $value_max\nGROUP BY 1,2\nORDER BY commit_timestamp",
          "refId": "A",
          "select": [
            [
              {
                "params": [
                  "$aggr(cachesize2) / $aggr(cachesize1)"
                ],
                "type": "column"
              }
            ]
          ],
          "table": "buildtimes",
          "timeColumn": "commit_timestamp",
          "timeColumnType": "int",
          "where": [
            {
              "name": "$__unixEpochFilter",
              "params": [],
              "type": "macro"
            },
            {
              "datatype": "smallint",
              "name": "",
              "params": [
                "exit_status",
                "=",
                "0"
              ],
              "type": "expression"
            },
            {
              "datatype": "varchar",
              "name": "",
              "params": [
                "project",
                "LIKE",
                "'%${project_filter:sqlstring}%'"
              ],
              "type": "expression"
            },
            {
              "datatype": "varchar",
              "name": "",
              "params": [
                "build_command",
                "LIKE",
                "'%${build_command_filter:sqlstring}%'"
              ],
              "type": "expression"
            },
            {
              "datatype": "int",
              "name": "",
              "params": [
                "cachesize2 / cachesize1",
                ">=",
                "$value_min"
              ],
              "type": "expression"
            },
            {
              "datatype": "int",
              "name": "",
              "params": [
                "cachesize2 / cachesize1",
                "<=",
                "$value_max"
              ],
              "type": "expression"
            }
          ]
        }
      ],
      "thresholds": [],
      "timeFrom": null,
      "timeRegions": [],
      "timeShift": null,
      "title": "🎈 cache size growth ratio 🎈",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "buckets": null,
        "mode": "time",
        "name": null,
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "format": "short",
          "label": "1:1",
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        },
        {
          "format": "short",
          "label": null,
          "logBase": 1,
          "max": null,
          "min": null,
          "show": true
        }
      ],
      "yaxis": {
        "align": false,
        "alignLevel": null
      }
    }
  ],
  "refresh": false,
  "schemaVersion": 22,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": [
      {
        "current": {
          "selected": false,
          "text": "",
          "value": ""
        },
        "hide": 0,
        "label": "project filter",
        "name": "project_filter",
        "options": [
          {
            "selected": false,
            "text": "",
            "value": ""
          }
        ],
        "query": "",
        "skipUrlSync": false,
        "type": "textbox"
      },
      {
        "current": {
          "selected": false,
          "text": "",
          "value": ""
        },
        "hide": 0,
        "label": "build_command filter",
        "name": "build_command_filter",
        "options": [
          {
            "selected": false,
            "text": "",
            "value": ""
          }
        ],
        "query": "",
        "skipUrlSync": false,
        "type": "textbox"
      },
      {
        "allValue": null,
        "current": {
          "selected": false,
          "text": "avg",
          "value": "avg"
        },
        "hide": 0,
        "includeAll": false,
        "label": null,
        "multi": false,
        "name": "aggr",
        "options": [
          {
            "selected": false,
            "text": "max",
            "value": "max"
          },
          {
            "selected": true,
            "text": "avg",
            "value": "avg"
          },
          {
            "selected": false,
            "text": "min",
            "value": "min"
          }
        ],
        "query": "max,avg,min",
        "skipUrlSync": false,
        "type": "custom"
      },
      {
        "current": {
          "selected": false,
          "text": "0",
          "value": "0"
        },
        "hide": 0,
        "label": "|value| ≥",
        "name": "value_min",
        "options": [
          {
            "selected": false,
            "text": "0",
            "value": "0"
          }
        ],
        "query": "0",
        "skipUrlSync": false,
        "type": "textbox"
      },
      {
        "current": {
          "selected": false,
          "text": "1000000",
          "value": "1000000"
        },
        "hide": 0,
        "label": "|value| ≤",
        "name": "value_max",
        "options": [
          {
            "selected": false,
            "text": "1000000",
            "value": "1000000"
          }
        ],
        "query": "1000000",
        "skipUrlSync": false,
        "type": "textbox"
      }
    ]
  },
  "time": {
    "from": "now-30d",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": [
      "5s",
      "10s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m",
      "1h",
      "2h",
      "1d"
    ]
  },
  "timezone": "",
  "title": "FireBuild Dashboard",
  "uid": "FireBuild",
  "variables": {
    "list": []
  },
  "version": 1
}
