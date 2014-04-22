From: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] hugetlb_cgroup: explicitly init the early_init field
Date: Tue, 22 Apr 2014 15:01:04 +0800
Message-ID: <CAHz2CGXsvdtVdwZfyFAwtRHJ_vkeJZXtLv4fTGTYEeEwN7H6Qw__47739.7347371609$1398150113$gmane$org@mail.gmail.com>
References: <1398144620-9630-1-git-send-email-nasa4836@gmail.com>
	<CAJd=RBA6ZUZ2UBetmcwGciqY8snme-aY60ZhW9F=8CO6kDzMBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAJd=RBA6ZUZ2UBetmcwGciqY8snme-aY60ZhW9F=8CO6kDzMBA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hillf Danton <dhillf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux-MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, hillf,

On Tue, Apr 22, 2014 at 2:47 PM, Hillf Danton <dhillf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> But other fields still missed, if any. Fair?

yep, it is not fair.

Sure for this global variable struct, if not initailized, its all
fields will be initialized
to 0 or null(depending on its type).  The point here is no to deprive
the rights of
compiler/linker of doing this initialization, it is mainly for
documentation reason.
Actually this field's value would affect how ->css_alloc should implemented.

Concretely, if early_init is nonzero, then ->css_alloc *must not* call kzalloc,
because in cgroup implementation, ->css_alloc will be called earlier before
mm_init().

I don't think that the value of one field(early_init) has a so subtle
restrition on the
another field(css_alloc) is a good thing, but since it is there,
docment it should
be needed.


Thanks,
Jianyu Zhan
