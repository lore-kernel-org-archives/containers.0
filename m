From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: uts: don't pass an unsigned var as a signed int
Date: Tue, 23 Jun 2009 08:05:22 -0500
Message-ID: <20090623130522.GA17948@us.ibm.com>
References: <20090619203719.GA30093@us.ibm.com> <m3prczfs2m.fsf@pobox.com>
	<20090621001837.GA32394@hallyn.com> <m34ouaf942.fsf@pobox.com>
	<20090621191305.GA2499@hallyn.com> <4A40BF4F.9080704@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A40BF4F.9080704-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (legoater-GANU6spQydw@public.gmane.org):
> > would it be possible to put up a filter, either manual or
> > automatic, to send every patch that gets pushed on the current
> > ckpt git branch to the containers list, maybe with a [CKPT PUSH]
> > tag in the subject line?
> 
> you might want to use the 'post-receive' hook  like it's done on lxc-devel@ :
> 
> http://sourceforge.net/mailarchive/forum.php?thread_name=E1MF7MN-00089i-Oz%40fxgxhf1.ch3.sourceforge.com&forum_name=lxc-devel
> 
> Cheers,
> 
> C.

Thanks, neat idea.

As Nathan pointed out, it would be better (in terms of assuring upstream
maintainers of quality of the tree) to demand an ack *before* pushing to
git.  But even so, a post-receive hook would still be nice.

-serge
