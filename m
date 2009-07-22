From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFCv2][PATCH] flexible array implementation
Date: Wed, 22 Jul 2009 15:03:26 -0700
Message-ID: <1248300206.24021.347.camel__25028.0665736229$1248300557$gmane$org@nimitz>
References: <20090721220017.60A219D3@kernel>
	<20090722183018.GE5878@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722183018.GE5878-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-07-22 at 11:30 -0700, Matt Helsley wrote:
> > +static int __check_part_and_nr(struct flex_array *fa,
> > +                            int part_nr, int element_nr)
> > +{
> > +     if (part_nr >= __nr_part_ptrs() ||
> > +         element_nr > fa->nr_elements) {
> > +             WARN(1, "bad flexible array element number: %d > %d\n",
> > +                     element_nr, fa->nr_elements);
> > +             return -EINVAL;
> > +     }
> > +     return 0;
> > +}
> 
> Should the above be inline? Does it make sense to optimize the "common"
> case and penalize inappropriate access by putting an unlikely() in
> there? Or is it too early for this stuff?

I think I'll leave it to the compiler for now.  Since we also don't have
a single user, I don't think we have an idea how hot of a path this
might get used in.

> I wonder how the *, /, and % ops will affect things that otherwise
> would have been reduced to shifts and masks -- especially on the
> "smaller" embedded archs.

I'm generally fine with rounding all these sizes to powers-of-two.  But,
I do think it's a wee bit premature at this point.

-- Dave
