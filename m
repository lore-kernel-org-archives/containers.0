From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Fuse in userns
Date: Wed, 11 Nov 2015 10:24:33 -0600
Message-ID: <8737wcwlku.fsf@x220.int.ebiederm.org>
References: <CAJFSNy5ur4=PKiQC3_h9eL96vQcmtH3A=3bGujHS5ndnNC+ROQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAJFSNy5ur4=PKiQC3_h9eL96vQcmtH3A=3bGujHS5ndnNC+ROQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Nikolay Borisov's message of "Wed, 11 Nov 2015 16:49:44 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <n.borisov-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org>
Cc: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, SiteGround Operations <operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org>, Marian Marinov <mm-108MBtLGafw@public.gmane.org>
List-Id: containers.vger.kernel.org

Nikolay Borisov <n.borisov-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org> writes:

> Hello Eric,
>
> I'd like to ask you what it would take to have proper support of Fuse
> inside usernamespaces. I've looked through the code of fuse and I can
> see some things are specifically coded to prevent creating a mount
> inside userns. E.g. hard-coded usage of init_user_ns or the check
> inside fuse_fill_super to make sure the fd is obtained from the
> init_user_ns. I have also read your argument here:
> https://lkml.org/lkml/2012/11/12/591
>
> So I'm interested in knowing the following:
>  * Are you still actively working on making fuse mountable in non-root
> userns, if not is the partial patch available somewhere? I might be
> able to do some work on that and hopefully make it upstreamable.

Yes.

> * If the code is not available can you explain what are the main
> hurdles in getting this to work? In my experiments I;ve hacked fuse
> and I'm able to mount glusterfs inside an LXC container but I suspect
> I might have broken some subtle security aspect :)

The subtle security aspect is definitely where things get tricky.

fuse is unique compared to the existing filesystems that we can mount in
a user namespace in that it has an untrusted backing store.  Dealing
with an untrusted backing store raises some new challenges with respect
to the vfs, etc.

The current plan is to deal with all of the weird tricky generic issues
in the vfs, and then add support for fuse.  Solving the backing store
issues generically instead of a fuse specific way pushes the
conversation to the right places and with the appropriate people.

Seth Forshe has put in a lot of work to make this happen, and his
changes are almost there.  I had hoped to just do a quick review of his
work and merge the code this last kernel development cycle.
Unfortunately the issues are vast enough and subtle enough that it is
easy to drop a detail or two.  So I figure a very close review of what
Seth has done is needed so that we do not introduce new issues.

Hopefully colds etc won't preven that from happening this cycle.

I am also beginning to suspect there is a case for a general review of
everything that is allowed in user namespaces to see if it is possible
to spot anything that has been overlooked.

Eric
