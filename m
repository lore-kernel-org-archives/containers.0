From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: stop checkpointed process
Date: Sun, 29 Nov 2009 09:45:35 -0600
Message-ID: <20091129154535.GA1115@us.ibm.com>
References: <2f0d4790911261815s6ba92aa1w9dce17b0c582bb62@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2f0d4790911261815s6ba92aa1w9dce17b0c582bb62-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jianwei Liao <liaotoad1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Jianwei Liao (liaotoad1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> hi all,
> I am using ckpt-v18, everything is fine.
> i have read some of the code of ckpt, but i was wondering that where does
> kernel module to stop the checkpointee? (something related to context?) i
> hope you can point me out how to find such stuff.
> Can i use SIGSTOPand SIGCONT to do such things?
> Thank you very much.
> Liao

Userspace should do this in advance by using the freezer cgroup.  So
for instance if you are wanting to checkpoint /usr/bin/myapp, then
one way to do it is:

	(terminal 1)
	mkdir -p /cgroup
	mount -t cgroup -o freezer freezer /cgroup
	mkdir /cgroup/myapp

	(terminal 2)
	echo $$ > /cgroup/myapp/tasks
	/usr/bin/myapp

	(terminal 1)
	echo FROZEN > /cgroup/myapp/freezer.state
	pid=`pidof myapp`
	checkpoint $pid > myapp.ckpt
	echo THAWED > /cgroup/myapp/freezer.state

If the application hasn't been frozen using the freezer cgroup,
then sys_checkpoint() will return -EBUSY.

-serge
