From: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 0/2] cr: Introduce s390x checkpoint/restart code
Date: Thu, 15 Jan 2009 10:39:55 +0100
Message-ID: <1232012395.30152.13.camel@localhost>
References: <20090115050523.GA10415@us.ibm.com>
Reply-To: schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090115050523.GA10415-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2009-01-14 at 23:05 -0600, Serge E. Hallyn wrote:
> Hi,
> 
> here is a first stab at extending Oren's application c/r patchset
> (http://lkml.org/lkml/2008/12/29/38) to s390.  I pretty much spent a day
> or two looking through the s390 include and .S files and then took a
> stab, so I won't be surprised to find these patches (and myself) the
> subject of ridicule.  For instance, I'm really not *sure* whether I
> should be backing up the acrs registers (some s390 docs suggested
> userspace could use them), the ksp, or the vdso_base.  But one thing
> I've got going for me at least...  it works!

The access registers need to be saved, a0/a1 contain the TLS pointer and
the user can store anything to a2-a15. The ksp does not have to be
stored as it cannot contain an important value. If it would then we'd
have kernel state which would break checkpoint/restart. The restart code
needs to come up with a sensible initial value for ksp though. The
vdso_base code needs to be stored as well. 

This hunk from patch #2 worries me a bit:

 struct cr_hdr_mm_context {
-       __s16 unimplemented;
+#if 0
+       unsigned long asce_bits;
+       unsigned long asce_limit;
+       int noexec;
+       int has_pgste;
+       int alloc_pgste;
+#endif
+       unsigned long vdso_base;
 };

The page table can have 2, 3, or 4 levels and if KVM is used the page
tables have a the pgste table attached to them. If that is ignored then
the creation of the process address space on restart is definitly
broken.

> Please take a look, point and laugh, and maybe even explain
> what's so funny and how to improve them.

It doesn't look THAT bad ;-)

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.
