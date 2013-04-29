From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: hi regarding the Linux containers
Date: Mon, 29 Apr 2013 08:25:09 -0500
Message-ID: <20130429132509.GB30159@sergelap>
References: <CAHfs=Wzf5cQqoa4Q3EuG3rfp7qQAmDWGfpQQ5Z3H5fzVG3puVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAHfs=Wzf5cQqoa4Q3EuG3rfp7qQAmDWGfpQQ5Z3H5fzVG3puVA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Harini Donthineni <harini.donthineni-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

netns has been supported for quite some time in the kernel, as has
setns() to netns.  You don't need to apply any patches.  For
documentation see the manpages: setns(2), unshare(2), clone(2), and
finally the still-in-development namespaces(7), for which you can
see an early draft at https://lkml.org/lkml/2013/3/15/56

Quoting Harini Donthineni (harini.donthineni-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> hi ,
> I have few queries in this area,can u pls help me ?
> 
> I am trying to create virtual router using test Linux kernel code 3.8
> 
> so my question is
> 
> looks like this can be done by container concept.various approaches are
> 
> lxc containers,openvz which ur discussing.
> 
> 
> 
> so my question is only using the Linux kernel src code can i develop a
> virtual router sample program with out using Openvz like using setns and
> netns .
> 
> 
> is netns supported by Linux kernel latest ?
> 
> 
> do i need to exclusively download and incorporate the patches ?
> 
> can u pls let me where can i get the documentation with sample examples for
> the same.
> 
> 
> 
> -- 
> Thanks & Regards
> Harini
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
