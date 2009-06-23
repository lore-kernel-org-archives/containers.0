From: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: uts: don't pass an unsigned var as a signed int
Date: Tue, 23 Jun 2009 13:41:03 +0200
Message-ID: <4A40BF4F.9080704@free.fr>
References: <20090619203719.GA30093@us.ibm.com>
	<m3prczfs2m.fsf@pobox.com>	<20090621001837.GA32394@hallyn.com>
	<m34ouaf942.fsf@pobox.com> <20090621191305.GA2499@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090621191305.GA2499-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

> would it be possible to put up a filter, either manual or
> automatic, to send every patch that gets pushed on the current
> ckpt git branch to the containers list, maybe with a [CKPT PUSH]
> tag in the subject line?

you might want to use the 'post-receive' hook  like it's done on lxc-devel@ :

http://sourceforge.net/mailarchive/forum.php?thread_name=E1MF7MN-00089i-Oz%40fxgxhf1.ch3.sourceforge.com&forum_name=lxc-devel

Cheers,

C.
