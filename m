From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: warning =?windows-1252?Q?=E0_la_compilation_de_mcr?=
Date: Thu, 27 May 2010 13:22:53 +0200
Message-ID: <4BFE560D.2080302@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Il y a ces warnings sur x86_64 depuis un petit moment:

srm_proc.c: In function =91dump_proctree=92:
srm_proc.c:1039: warning: cast from pointer to integer of different size
srm_proc.c: In function =91dump_thread_group_leader_state=92:
srm_proc.c:1072: warning: cast from pointer to integer of different size
srm_proc.c: In function =91dump_thread_state=92:
srm_proc.c:1093: warning: cast from pointer to integer of different size
srm_proc.c: In function =91dump_task=92:
srm_proc.c:1114: warning: cast from pointer to integer of different size
srm_proc.c: In function =91srm_proc_dump=92:
srm_proc.c:1134: warning: cast to pointer from integer of different size
srm_proc.c:1148: warning: cast to pointer from integer of different size
srm_proc.c:1153: warning: cast to pointer from integer of different size
srm_proc.c:1157: warning: cast to pointer from integer of different size
