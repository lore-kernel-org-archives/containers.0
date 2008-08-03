From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/6] user namespaces: add user_ns to super block
Date: Sat, 2 Aug 2008 19:37:13 -0500
Message-ID: <20080803003713.GA13842@us.ibm.com>
References: <20080726002700.GA29686@us.ibm.com>
	<20080726002754.GD29874@us.ibm.com>
	<m13altislf.fsf@frodo.ebiederm.org>
	<1217285230.25300.19.camel@localhost.localdomain>
	<20080729180515.GB365@us.ibm.com>
	<m13alscx7e.fsf@frodo.ebiederm.org>
	<20080802000609.GA10211@us.ibm.com>
	<m1wsj0i3td.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1wsj0i3td.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Ok I wasn't thinking right.  We still can't get to a user_ns from
> > an inode *.
> >
> > So playing with this a bit tonight, it seems like the best way
> > to pass the user_namespace up to the fs is just to define new
> > super_operations which handle the conversions.  Something like
> > the following.
> 
> I'm pretty certain you want to pass in the entire inode instead
> of just inode->i_uid.  That would allow you to pass one less argument
> and give the filesystems more information to work with.
> 
> Eric

Oh yes of course, the fs will want the whole inode.  Will change that.

And I suppose in that case I may as well have just one function
to convert both uid and gid.

Thanks.

-serge
