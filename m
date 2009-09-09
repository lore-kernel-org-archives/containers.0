From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: restart (mktree) program usage
Date: Wed, 09 Sep 2009 18:26:04 -0400
Message-ID: <4AA82B7C.8080107@librato.com>
References: <20090909055636.GA27622@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090909055636.GA27622-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> I have a usage question on the 'restart' (formerly mktree) program.
> 
> In the following container c/r case: 
> 
> 	- create a container
> 	- log in to the container,
> 	- restore filesystem(s) from snapshot
> 	- restart application from checkpoint

FWIW, I'd expect that future versions of 'restart' will be capable
of doing this entire setup, (filesystem(s) included), as it matures.

Note that this use case that you suggest will only work to restart
subtrees; it is unsuitable for full containers (with pids) because
the pid of init (1) will already be in use.

Perhaps we should think of some "plugin" architecture for 'restart'
that will allow the user to ask it to execute some work at between
creating a new container and actually restarting into it ?

> 
> On restart, suppose the user wants to restore the original pids.
> But he does not want to create a new pid-ns, (since he just created
> the container, and is sure the original pids are available).
> 
> To accomplish this the user has to specify the arguments in the following
> order right  (since -pids implies --pidns).
> 
> 	restart --pids --no-pidns
> 
> IOW, the order of the arguments matters.
> 
> Would it be easier to understand if --pids did not imply --pidns ?

Either that, or simply change the semantics such that the order
does not matter:

> 
> (Or in fact the reverse seems to make more sense -i.e --pidns implies
> --pids, with a new option, --no-pids if user absolutely hates the pids
> he was dealt before checkpoint :-)
> 
> 	$ restart
> 		don't create pid ns, don't try to restore pids
> 
> 	$ restart --pids
> 		try to restore original pids, don't create pid-ns
> 
> 	$ restart --pidns
> 		create new pid-namespace and restore original pids
> 
> 	$ restart --pidns --no-pids
> 	$ restart --no-pids --pidns
> 		create new pid-namespace, DO NOT restore pids

Yes, something like that.

Oren.

> 
> Or maybe drop implying and let user explicitly specify one, none or
> both of --pids, --pidns ?
> 
> Sukadev
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
