From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Testing CGROUP inside CONTAINER]: BUG#2
Date: Thu, 4 Dec 2008 10:52:21 -0600
Message-ID: <20081204165220.GA11482@us.ibm.com>
References: <1228378480.4234.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1228378480.4234.36.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
Cc: iranna.ankad-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, sudhirkumarmalik-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, dhavalgiani-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Rishikesh K. Rajak (risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
>     -  Execute the following command inside container
>      delta:~ # mkdir /cpu
>      delta:~ # mount -t cgroup -ocpu cgroup /cpu
> 
>     -   delta:~ # umount /cpu
>         delta:~ # mount
>             ...
>             cgroup on /cpu type cgroup (rw,cpu)
>             cgroup on /cpu type cgroup (rw,cpu)
>             cgroup on /cpu type cgroup (rw,cpu)
>         delta:~ # umount /cpu
>             umount: cgroup: not found
>             umount: /cpu: not mounted
>             umount: cgroup: not found
>             umount: /cpu: not mounted
>             umount: cgroup: not found
>             umount: /cpu: not mounted
>             umount: cgroup: not found
>             umount: /cpu: not mounted

This really sounds to me like a bug in your mount and
umount commands.  When I do those steps in a container,
just typing 'mount' no longer shows /cpu mounted.

(If I had to guess at something, I'd say you have
/etc/mtab linked to /proc/mounts, and something with
that is going wrong, but it could be not that)

Check /proc/self/mounts before and after each step,
compare to /etc/mtab.

And try doing mount -n and umount -n.

-serge
