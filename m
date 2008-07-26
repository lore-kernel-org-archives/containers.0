From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [PATCH 1/6] user namespaces: introduce
	user_struct->user_namespace relationship
Date: Fri, 25 Jul 2008 22:31:04 -0500
Message-ID: <20080726033104.GA8941@us.ibm.com>
References: <20080726002700.GA29686@us.ibm.com>
	<20080726002725.GA29874@us.ibm.com>
	<20080726020731.GA5115@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080726020731.GA5115-QDJVlCTZ4KWTKS93B3g+7KFoa47nwP16@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Fri, Jul 25, 2008 at 07:27:25PM -0500, Serge E. Hallyn wrote:
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -600,6 +600,7 @@ struct user_struct {
> >  	/* Hash table maintenance information */
> >  	struct hlist_node uidhash_node;
> >  	uid_t uid;
> > +	struct user_namespace *user_namespace;
> 
> Call it "user_ns" please,

Odd, I had the same thought, but seem to have applied at the wrong
patch (please see patch 2).

Thanks.

>  and file "user_ns.c".

I'm ok with that, but that file has existed for quite some time
by now, so I'm not introducing it.

If noone objects, I'll rename the file (as well as
include/linux/user_namespace.h).

thanks,
-serge
