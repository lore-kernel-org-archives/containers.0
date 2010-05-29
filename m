From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: NFS Kernel server inside a container
Date: Sat, 29 May 2010 15:11:36 -0700
Message-ID: <m1y6f2gxyf.fsf@fess.ebiederm.org>
References: <187493.1732.qm@web36105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <187493.1732.qm-4AwnY8zbAf+vuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org> (Martin Fick's
	message of "Tue\, 18 May 2010 14\:09\:26 -0700 \(PDT\)")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Martin Fick <mogulguy-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Martin Fick <mogulguy-/E1597aS9LQAvxtiuMwx3w@public.gmane.org> writes:

> --- On Tue, 5/18/10, Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org> wrote:
>> 18.05.2010 22:51, Martin Fick wrote:
>> >    FATAL: Could not load
>> /lib/modules/2.6.32-trunk-vserver-686/modules.dep: No such
>> file or directory
>> 
>> Obviously you have to have necessary modules in the
>> container in order to _load_ them.  But it is simpler
>> to pre-load all required modules from the host system
>> instead.
>
> Right, I actually ran the kernel server on the host 
> too, just to make sure the modules were loaded.
>
>> Actually it does not work even after solving
>> module issue.  I asked about this very issue
>> at the end of last year (I think), but no one
>> answered.  It looks like knfsd threads are
>> working in "global" (i.e host) namespace, not
>> in the container namespace, or the said
>> namespace isn't being set up correctly in
>> the kernel.  In any way, nfs service needs
>> to be "containerized" properly before being
>> useful inside a container, which is not done
>> currently, it seems.
>
> Is anyone working on this?  It certainly
> would be a very useful feature. :)  If it
> is only a matter of setting up the 
> container appropriately, any ideas how to
> do that? Thanks,

I remember doing some work a while ago and to ensure it fails
properly.  Getting knfsd updated to work in a network namespace should
be possible, but there are a lot of interactions, and isn't immediately
clear how the struct net would be passed to the functions that need it.

In short it looked doable, but I don't have any immediate plans to make it
happen but I would like to see it happen.

Eric
