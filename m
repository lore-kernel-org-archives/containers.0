From: vaibhav shinde <v.bhav.shinde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: cgroup block io issue
Date: Tue, 14 Aug 2012 15:56:14 +0530
Message-ID: <CAB5gotvNMkJtHhzYz3brkhqkSLziBxU4HZx7XksnrDxbJ6ph+g@mail.gmail.com>
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
List-Id: containers.vger.kernel.org

Hi all,

I am facing the same issue regarding cgroup block io behavior as mentioned
by Naveen in the below link
*http://lkml.org/lkml/2012/7/27/35*

I am testing using following tunnable parameters-

*              blkio.throttle.write_bps_device (set to different cgroups
depending on default readings)*
*              blkio.throttle.read_bps_device *
*              blkio.throttle.write_iops_device * *
*
*              blkio.throttle.read_iops_device * *
*
*              blkio.weight (range 100-1000)*

I tested once using a user level application that creates few processes
with two threads in each process.
The threads perform read and write operations using 'dd' command and
records the readings.

The readings achieved from above test appear unpredictable to me.

Can you suggest any method or testcase for analyzing the behavior of
 cgroup block io in case of threads.

Thanks in advance


Kind Regards,
Vaibhav Shinde
*
*
