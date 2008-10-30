From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Thu, 30 Oct 2008 15:03:34 -0500
Message-ID: <20081030200334.GA20459@us.ibm.com>
References: <1225219047.12673.182.camel@nimitz>
	<4909FAA8.5000107@cs.columbia.edu>
	<20081030192817.GA16340@us.ibm.com>
	<490A0F67.5000303@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <490A0F67.5000303-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> > What Dave is suggesting (as I understand it) is just changing the way
> > the data is shipped between kernel and user-space.  But to continue with
> > sys_checkpoint() and sys_restart().  So I think it's a less fundamental
> > change than you are thinking.
> 
> Probably true, if you ignore the tree he used to illustrate the idea :o
> If we agree on the 'blob' (or nearly 'blob') approach, he should suggest
> to export a single file (or one file per task, but that's _it_).

Well no.  I'm saying that the problem with cryo was that you had to use
tons of different APIs - and introduce a few new ones - to grab info
about various resources using their own API.  Yes Dave looks to be
making you grab all the info in fine-grained pieces through individual
files, but each bit of info is consumed using the exact same API.

> Can you comment on point 3, that is --
> 
>   3. Your approach doesn't play well with what I call "checkpoint that
>   involves self". This term refers to a process that checkpoints itself
>   (and only itself), or to a process that attempts to checkpoint its own
>   container.  In both cases, there is no other entity that will read the
>   data from the file system while the caller is blocked.

This is where I seem to recall Dave mentioning some crazy scheme where
the task would clone itself and have its clone do the pulling.

Don't get me wrong - I'm not sure what Dave's intentions are, but I
agree with you that we should keep working on pushing your patchset.
If we get a nack based on the set_fs() stuff then we know to go with
Dave's approach (or some other), otherwise Dave can keep pursuing his
idea in his sandbox.  But I do think his idea is cool.  Not all cool
ideas end up being workable, so we'll see...

/me now goes to try lxc-checkpoint with Oren's patches.

-serge
