From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/6] user namespace : add the framework
Date: Mon, 16 Jul 2007 09:38:48 -0500
Message-ID: <20070716143848.GA14988@sergelap.austin.ibm.com>
References: <20070604193957.GA19331@sergelap.austin.ibm.com>
	<20070604194024.GA21703@sergelap.austin.ibm.com>
	<20070715183132.e31a2064.akpm@linux-foundation.org>
	<20070716143443.GA7393@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070716143443.GA7393-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, xemul-3ImXcnM4P+0@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> > On Mon, 4 Jun 2007 14:40:24 -0500 "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > 
> > > Add the user namespace struct and framework
> > > 
> > > Basically, it will allow a process to unshare its user_struct table, resetting
> > > at the same time its own user_struct and all the associated accounting.
> > > 
> > > A new root user (uid == 0) is added to the user namespace upon creation.  Such
> > > root users have full privileges and it seems that theses privileges should be
> > > controlled through some means (process capabilities ?)
> > 
> > The whole magical-uid-0-user thing in this patch seem just wrong to
> > me.  
> > 
> > I'll merge it anyway, mainly because I want to merge _something_ (why oh
> > why do the git-tree guys leave everything to the last minute?) but it strikes
> > me that there's something fundamentally wrong whenever the kernel starts
> > "knowing" about the significance of UIDs in this fashion.
> 
> $(&(%
> 
> I thought I disagreed, but now I'm pretty sure I completely agree.
> 
> 'root_user' exists in the kernel right now, but the root_user checks
> which exist (in fork.c and sys.c) shouldn't actually be applied for root
> in a container, since the container may not be trusted.

By the way, I don't think these two uses of 'user == &root_user' are
legitimate.  CAP_SYS_RESOURCE should probably be checked for both.  Hah,
it already is in fork.c, in addition to root_user check.

But I guess I should take that up elsewhere.

thanks,
-serge
