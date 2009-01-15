From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Performance of netns with sysfs
Date: Thu, 15 Jan 2009 12:57:28 -0800
Message-ID: <87ocy8thhj.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: Guenter Roeck <groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>, Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Serge E. Ha
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

There has been some discussion lately about network namespaces and the
interaction with sysfs.  With the introduction of Guenter's ipcgroup
patches, there was also the question of how feasible it is to create
thousands of network namespaces.  So, I decided to see if I could even
create thousands of veth pairs, and if so move them into thousands of
network namespaces.  I was pleased to see that the system didn't fall
over, but found that the process slowed significantly with higher
numbers if sysfs was enabled.  I thought it would be prudent to post
some numbers.

I first tested creating 1000 and 2500 veth pairs, attaching one side
to a bridge with and without sysfs.  Next I created 2500 network
namespaces, along with 2500 veth pairs.  One side of each pair was
attached to a bridge and the other was moved into the namespace.  The
results are:

  1000 veth pairs:        8x slower with CONFIG_SYSFS
  2500 veth pairs         4.5x slower
  2500 netns, veth pairs: 6x slower

The tests were done with hal disabled, attaching every third veth
device to a different bridge (to overcome the limit of 1023 taps per
bridge).

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
