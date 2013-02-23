From: Sean Chen <win826-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: cgroups memory controller causing swap or oom kill
Date: Sat, 23 Feb 2013 17:39:10 -0500
Message-ID: <CA+AUh-HytiYveYcnwsojOxAwVVNBhnGwGfZF8s_VsvbEFsyOTg@mail.gmail.com>
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

i am new to the list and have a quick q on cgroups memory subsystem.
 please let me know if there's a better mailing list / forum or usenet
group for the topic.

let us say i have correctly set up cgroups memory subsystem (just memory,
no memsw / swap limit for now) have a group called mg1.   mg1 has a memory
limit in bytes as 200M.  then i run a simple program hello inside mg1.
the program is very simple,  it runs mallocs for A megabytes  in a loop for
B times, after each allocation it sets the allocated buffer to 'a' with
memset ( to defeat overcommit ).  the program hello can also sleep for D
seconds every several allocations and prints how much it's allocated every
so often.  The allocated and memset'ed buffer is leaked by intention in the
subsequent malloc call to increase memory consumption of the program.   I
monitor the memory and swap usage with htop in another window/shell.

the question is, sometimes,  the hello program gets killed outright as it's
reaching the memory cgroup's limit.  Other times,  with the same exact
limit and setup,  (it appears) as the memory limit is approaching, cgroup
would free/reclaim some RAM by swapping / paging out, thus allowing the
program to successfully allocate desired A*B  megs.   It would seem
introducing or increasing the delay every so often in the malloc / memset
loop helps the chance or success.  I want to understand this a little more
because I'd prefer the program to not be killed especially i've a lot of
swap space at the time of the cgroup oom/kill.

I don't know Linux mm or the LRU page reclaim algorithm much.  Is there a
delay of some # of seconds that the  in memory pages are marked inactive
allowing them to be paged out? If so what's the typical number in a recent
latest kernel?   I just need to understand this topic a bit better to take
advantage of the cgroup feature in managing some production processes.
 Any leads are welcome.

Thanks
SeanC
