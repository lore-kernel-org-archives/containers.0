From: Andre Nathan <andre-K36Kqf6HJK439yzSjRtAkw@public.gmane.org>
Subject: About cgroup memory limits
Date: Thu, 10 May 2012 18:38:23 -0300
Message-ID: <1336685903.15687.0.camel@andre>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: andre-K36Kqf6HJK439yzSjRtAkw@public.gmane.org, michel-K36Kqf6HJK439yzSjRtAkw@public.gmane.org
List-Id: containers.vger.kernel.org

Hello

I'm doing some tests with LXC and how it interacts with the memory
cgroup limits, more specifically the memory.limit_in_bytes control file.

Am I correct in my understanding of the memory cgroup documentation[1]
that the limit set in memory.limit_in_bytes is applied to the sum of the
fields 'cache', 'rss' and 'mapped_file' in the memory.stat file?

I am also trying to understand the values reported in memory.stat when
compared to the statistics in /proc/$PID/statm.

Below is the sum of each field in /proc/$PID/statm for every process
running inside a test container, converted to bytes:

       size  resident     share     text  lib       data  dt
  897208320  28741632  20500480  1171456    0  170676224   0

Compare this with the usage reports from memory.stat (fields total_*,
hierarchical_* and pg* omitted):

cache                     16834560
rss                       8192000
mapped_file               3743744
swap                      0
inactive_anon             0
active_anon               8192000
inactive_file             13996032
active_file               2838528
unevictable               0

Is there a way to reconcile these numbers somehow? I understand that the
fields from the two files represent different things. What I'm trying to
do is to combine, for example, the fields from memory.stat to
approximately reach what is displayed by statm.

Thank you in advance,
Andre

[1] http://www.kernel.org/doc/Documentation/cgroups/memory.txt
