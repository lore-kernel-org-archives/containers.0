From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFCv2][PATCH] flexible array implementation
Date: Wed, 22 Jul 2009 08:02:35 -0700
Message-ID: <1248274955.24021.5.camel__2122.26765365831$1248275479$gmane$org@nimitz>
References: <20090721220017.60A219D3@kernel>
	<20090722070903.GG6281@cr0.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090722070903.GG6281-+dguKlz9DXUf7BdofF/totBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Amerigo Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-07-22 at 15:09 +0800, Amerigo Wang wrote:
> On Tue, Jul 21, 2009 at 03:00:17PM -0700, Dave Hansen wrote:
> >+static inline int __nr_part_ptrs(void)
> 
> How about __nr_ptrs_in_part()?

That would be fine except it is the number of part pointers in the base.
I guess you're proving that I named it horribly. :)

> >+static int fa_index_inside_part(struct flex_array *fa, int element_nr)
> >+{
> >+	return (element_nr % __elements_per_part(fa->element_size));
> >+}
> >+
> >+static int offset_inside_part(struct flex_array *fa, int element_nr)
> 
> How about index_in_part()?

Yeah, I guess that's decent.  I'll go see how it feels when it gets
used.

-- Dave
