From: Vishnumurthy Prabhu <prabhuvishnumurthy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: c/r support on FUSE filesystems.
Date: Sun, 3 Apr 2011 11:20:58 +0530
Message-ID: <AANLkTi=pFfJOaNdaxZFZMe8vhQFO0XA_p0aq6jXuVzY6@mail.gmail.com>
References: <AANLkTikPaUYrX8cKQMehNCL6bCjPBVkNa4G1Fs_Fu4XV@mail.gmail.com>
	<20110401220021.GO22601@count0.beaverton.ibm.com>
	<AANLkTi=Z4HACdfGNcfz2J2FXUC7GsODMcGuzzCTLddYc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=e0cb4e8873eb5db8eb049ffd3bd8
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTi=Z4HACdfGNcfz2J2FXUC7GsODMcGuzzCTLddYc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

--e0cb4e8873eb5db8eb049ffd3bd8
Content-Type: text/plain; charset=ISO-8859-1

Patch resubmitted!!
New file(fuse-kcr.c) should go to fs/fuse/ directory.
I will look into unliked files and update you soon!

regards,
Vishnumurthy Prabhu

On Sat, Apr 2, 2011 at 7:29 AM, Vishnumurthy Prabhu <
prabhuvishnumurthy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Thank you very much for your kind and immediate reply!
> first thing, I do agree that this is not a submittable patch and as you
> said, I just 'diff' ed two linux sources(having with FUSE-cr support that is
> what I modified and non FUSE-cr support).
> what I wanted was to inform to community about FUSE-cr implementation and
> comments on issues involved with that implementation.
>
> .
> .
>
> .
>
> >Can you tell us about the testing you've done with this? What kind of
> >additions/changes does this make to the FUSE userspace API? Can you
> >please describe how it's supposed to work with FUSE userspace code?
>
> I have tested with two simple usecases(I know, it might not be sufficient).
> they are, fuse-zip(fuse based filesystem for accessing zip files) and
> simple-fuse(filesystem implementation in memory buffer). At user-space code,
> I didn't do much modifications, I just added call back handles for
> checkpointing in fuse library similar to that of other handles(open, close,
> read, write etc) thinking that I might need those. but I never made use of
> those. Thats why, if you have seen the code(fuse_kcr.c ie, a C file that I
> have attached), though I wrote a code piece for user-space communication, I
> have commented its use in actual checkpoint function and it just uses the
> same approach as that of generic file checkpoint. According to present
> implementation, user-space(fuse library or filesystem program) is unaware of
> what is going on during checkpointing and restart. It just considers every
> call as like others(ie open, read, write, close).
>
> MY CLAIM is that all required accounting information of an open file is
> managed at kernel space(file object) and At user space, it just get a
> request and replies to that. All information related to state of open file
> is supplied from kernel space.
>
> ASSUMPTION:  during checkpoint and restart mount remains same. in fact, I
> hope there is no unmount and remount of userspace program. because, here the
> support is for checkpointing file descriptors that involve fuse related
> files so I dont think we need to bother about user implemented filesystem.
>
> I wanted to know any issues related to above comments?
>
> .
> .
>
> .
> >>       .compat_ioctl   = fuse_file_compat_ioctl,
> >>      .poll           = fuse_file_poll,
> >> + //#ifdef CONFIG_CHECKPOINT
> >> +     .checkpoint     = fuse_file_checkpoint,
> >> + //#endif
>
> >Why are these cpp lines commented out?
>
> I know  I need to refine the patch file one thing and I commented out these
> line because I was compiling fuse kernel module as loadable one so compiler
> never used to take this checkpoint ops(I dont know why?) when #ifdef was
> present. but in actual source compilation with kernel, I have removed the
> comments.
> .
> .
>
> .
> >Is the content below the missing pair of files?
>
> >> /*
> >>fuse_cr: Checkpoint-Restart implementation for FUSE filesystem kernel
> module.
> >>
> >> Authors: Manoj Kumar and Vishnumurthy Prabhu
> >>         NITK Surathkal
> >>
> >>*/
> .
> .
> .
>
> they are the two new additions to fuse kernel module.
>
>
> >> /*
> >>       FUSE filesystem .It needs special handling
> >>       {
> >>               .file_name = "FUSE",
> >>               .file_type = CKPT_FILE_FUSE,
> >>               .restore = fuse_file_restore,
> >>       },
> >> */
>
> >Huh? What's this comment supposed to tell us?
>
> It is just to tell I have added this code piece some where, need
> implementation and it is just a comment.
>
>
> >>
> >> struct ckpt_hdr_file_fuse {
> >>      struct ckpt_hdr_file common;
> >>
> >> } __attribute__((aligned(8)));
>
> >This should be in include/linux/checkpoint_hdr.h *except* since it
> >doesn't need anything besides the ckpt_hdr_file I don't see why you
> >don't just use that struct instead.
>
> I kept seperate structure because there might have need to add few more
> variable in this structure later on. I didnt move it to checkpoint_hdr.h
> just because to avoid messing with large number of files. but once
> everything is settled, I hope we can do that.
> .
> .
> .
> >> int fuse_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
> >> {
> >>   int ret;
> >>    struct ckpt_hdr_file_fuse *h;
> >>
> >>       if (d_unlinked(file->f_dentry)) {
> >>               ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files
> unsupported\n",
> >>                        file);
> >>               return -EBADF;
>
> >Unlinked files are important too. Have you had a chance to review my
> >recent patches for unlinked files?
>
> No. I worked with one single kernel source so that frequent changes wont
> affect to this(fuse-cr).
>
> >>       }
> >>
> >>       h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
> >>       if (!h)
> >>               return -ENOMEM;
> >>
> >>       h->common.f_type = CKPT_FILE_FUSE;
> >>
> >>       ret = checkpoint_file_common(ctx, file, &h->common);
> >>       if (ret < 0)
> >>               goto out;
> >>       ret = ckpt_write_obj(ctx, &h->common.h);
> >>       if (ret < 0)
> >>               goto out;
> >>       ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
> >>
> >> //   ret = fuse_file_ckpt_send(file);
>
> >This looks like the only real difference from generic_file_checkpoint()
> yet
> >it's commented out. What's going on? Have you compiled this code?
> >Tested it?
>
>
> I compiled , tested with above mentioned test cases(fuse-zip and simple
> fuse). It worked fine. I thought not to mess with userspace and I wanted to
> know, whether it works fine or not. But it worked. yes, It is almost
> completely similar to generic file checkpoint.  I am looking for SUFFICIENT
> USECASEs for that where it also require user space support. Even I tried
> with non-commented code(fuse_file_ckpt_send()). then also it worked fine and
> even at userspace(I have checkpoint handles in user space fuse library
> similar to other handles). but I found there is nothing much to do with
> UserSpace. so I just commented out. It worked.
>
> It works fine with uncommented code also.
>
> so, I will update with refine code.
>
> thanks,
>
> regards,
> vishnumurthy prabhu
>

--e0cb4e8873eb5db8eb049ffd3bd8
Content-Type: text/x-patch; charset=US-ASCII; name="fuse-cr.patch"
Content-Disposition: attachment; filename="fuse-cr.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gm0u5kqr0

ZGlmZiAtLWdpdCBhL2ZzL2NoZWNrcG9pbnQuYyBiL2ZzL2NoZWNrcG9pbnQuYwppbmRleCA4N2Q3
YzZlLi40YjRiODNkIDEwMDY0NAotLS0gYS9mcy9jaGVja3BvaW50LmMKKysrIGIvZnMvY2hlY2tw
b2ludC5jCkBAIC03MTEsNiArNzExLDggQEAgc3RydWN0IHJlc3RvcmVfZmlsZV9vcHMgewogCQkJ
CSAgc3RydWN0IGNrcHRfaGRyX2ZpbGUgKnB0cik7CiB9OwogCitleHRlcm4gc3RydWN0IGZpbGUg
KmZ1c2VfZmlsZV9yZXN0b3JlKHN0cnVjdCBja3B0X2N0eCAqY3R4LCBzdHJ1Y3QgY2twdF9oZHJf
ZmlsZSAqcHRyKTsKKwogc3RhdGljIHN0cnVjdCByZXN0b3JlX2ZpbGVfb3BzIHJlc3RvcmVfZmls
ZV9vcHNbXSA9IHsKIAkvKiBpZ25vcmVkIGZpbGUgKi8KIAl7CkBAIC03NjAsNiArNzYyLDExIEBA
IHN0YXRpYyBzdHJ1Y3QgcmVzdG9yZV9maWxlX29wcyByZXN0b3JlX2ZpbGVfb3BzW10gPSB7CiAJ
CS5maWxlX3R5cGUgPSBDS1BUX0ZJTEVfRVZFTlRGRCwKIAkJLnJlc3RvcmUgPSBldmVudGZkX3Jl
c3RvcmUsCiAJfSwKKwl7CisJCS5maWxlX25hbWUgPSAiRlVTRSIsCisJCS5maWxlX3R5cGUgPSBD
S1BUX0ZJTEVfRlVTRSwKKwkJLnJlc3RvcmUgPSBmdXNlX2ZpbGVfcmVzdG9yZSwKKwl9LAkKIH07
CiAKIHN0YXRpYyB2b2lkICpyZXN0b3JlX2ZpbGUoc3RydWN0IGNrcHRfY3R4ICpjdHgpCmRpZmYg
LS1naXQgYS9mcy9mdXNlL01ha2VmaWxlIGIvZnMvZnVzZS9NYWtlZmlsZQppbmRleCBlOTVlZWI0
Li42YTI1NDA3IDEwMDY0NAotLS0gYS9mcy9mdXNlL01ha2VmaWxlCisrKyBiL2ZzL2Z1c2UvTWFr
ZWZpbGUKQEAgLTUsNCArNSw0IEBACiBvYmotJChDT05GSUdfRlVTRV9GUykgKz0gZnVzZS5vCiBv
YmotJChDT05GSUdfQ1VTRSkgKz0gY3VzZS5vCiAKLWZ1c2Utb2JqcyA6PSBkZXYubyBkaXIubyBm
aWxlLm8gaW5vZGUubyBjb250cm9sLm8KK2Z1c2Utb2JqcyA6PSBkZXYubyBkaXIubyBmaWxlLm8g
aW5vZGUubyBjb250cm9sLm8gZnVzZV9rY3IubwpkaWZmIC0tZ2l0IGEvZnMvZnVzZS9maWxlLmMg
Yi9mcy9mdXNlL2ZpbGUuYwppbmRleCBhOWY1ZTEzLi4yMzcxNmE0IDEwMDY0NAotLS0gYS9mcy9m
dXNlL2ZpbGUuYworKysgYi9mcy9mdXNlL2ZpbGUuYwpAQCAtMTk3NCw2ICsxOTc0LDcgQEAgaW50
IGZ1c2Vfbm90aWZ5X3BvbGxfd2FrZXVwKHN0cnVjdCBmdXNlX2Nvbm4gKmZjLAogCXJldHVybiAw
OwogfQogCitleHRlcm4gaW50IGZ1c2VfZmlsZV9jaGVja3BvaW50KHN0cnVjdCBja3B0X2N0eCAq
Y3R4LCBzdHJ1Y3QgZmlsZSAqZmlsZSk7CiBzdGF0aWMgY29uc3Qgc3RydWN0IGZpbGVfb3BlcmF0
aW9ucyBmdXNlX2ZpbGVfb3BlcmF0aW9ucyA9IHsKIAkubGxzZWVrCQk9IGZ1c2VfZmlsZV9sbHNl
ZWssCiAJLnJlYWQJCT0gZG9fc3luY19yZWFkLApAQCAtMTk5MSw2ICsxOTkyLDkgQEAgc3RhdGlj
IGNvbnN0IHN0cnVjdCBmaWxlX29wZXJhdGlvbnMgZnVzZV9maWxlX29wZXJhdGlvbnMgPSB7CiAJ
LnVubG9ja2VkX2lvY3RsCT0gZnVzZV9maWxlX2lvY3RsLAogCS5jb21wYXRfaW9jdGwJPSBmdXNl
X2ZpbGVfY29tcGF0X2lvY3RsLAogCS5wb2xsCQk9IGZ1c2VfZmlsZV9wb2xsLAorI2lmZGVmIENP
TkZJR19DSEVDS1BPSU5UCisJLmNoZWNrcG9pbnQJPSBmdXNlX2ZpbGVfY2hlY2twb2ludCwKKyNl
bmRpZgogfTsKIAogc3RhdGljIGNvbnN0IHN0cnVjdCBmaWxlX29wZXJhdGlvbnMgZnVzZV9kaXJl
Y3RfaW9fZmlsZV9vcGVyYXRpb25zID0gewpAQCAtMjAwNyw2ICsyMDExLDkgQEAgc3RhdGljIGNv
bnN0IHN0cnVjdCBmaWxlX29wZXJhdGlvbnMgZnVzZV9kaXJlY3RfaW9fZmlsZV9vcGVyYXRpb25z
ID0gewogCS51bmxvY2tlZF9pb2N0bAk9IGZ1c2VfZmlsZV9pb2N0bCwKIAkuY29tcGF0X2lvY3Rs
CT0gZnVzZV9maWxlX2NvbXBhdF9pb2N0bCwKIAkucG9sbAkJPSBmdXNlX2ZpbGVfcG9sbCwKKyNp
ZmRlZiBDT05GSUdfQ0hFQ0tQT0lOVAorCS5jaGVja3BvaW50CT0gZnVzZV9maWxlX2NoZWNrcG9p
bnQsCisjZW5kaWYJCiAJLyogbm8gc3BsaWNlX3JlYWQgKi8KIH07CiAKZGlmZiAtLWdpdCBhL2lu
Y2x1ZGUvbGludXgvY2hlY2twb2ludF9oZHIuaCBiL2luY2x1ZGUvbGludXgvY2hlY2twb2ludF9o
ZHIuaAppbmRleCBmNGY5NTc3Li4wZWFjZTZlIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L2No
ZWNrcG9pbnRfaGRyLmgKKysrIGIvaW5jbHVkZS9saW51eC9jaGVja3BvaW50X2hkci5oCkBAIC01
NjEsNiArNTYxLDggQEAgZW51bSBmaWxlX3R5cGUgewogI2RlZmluZSBDS1BUX0ZJTEVfRVBPTEwg
Q0tQVF9GSUxFX0VQT0xMCiAJQ0tQVF9GSUxFX0VWRU5URkQsCiAjZGVmaW5lIENLUFRfRklMRV9F
VkVOVEZEIENLUFRfRklMRV9FVkVOVEZECisJQ0tQVF9GSUxFX0ZVU0UsCisjZGVmaW5lIENLUFRf
RklMRV9GVVNFIENLUFRfRklMRV9GVVNFCiAJQ0tQVF9GSUxFX01BWAogI2RlZmluZSBDS1BUX0ZJ
TEVfTUFYIENLUFRfRklMRV9NQVgKIH07CkBAIC01ODEsNiArNTgzLDExIEBAIHN0cnVjdCBja3B0
X2hkcl9maWxlX2dlbmVyaWMgewogCXN0cnVjdCBja3B0X2hkcl9maWxlIGNvbW1vbjsKIH0gX19h
dHRyaWJ1dGVfXygoYWxpZ25lZCg4KSkpOwogCitzdHJ1Y3QgY2twdF9oZHJfZmlsZV9mdXNlIHsK
KwlzdHJ1Y3QgY2twdF9oZHJfZmlsZSBjb21tb247CisJCit9IF9fYXR0cmlidXRlX18oKGFsaWdu
ZWQoOCkpKTsKKwogc3RydWN0IGNrcHRfaGRyX2ZpbGVfcGlwZSB7CiAJc3RydWN0IGNrcHRfaGRy
X2ZpbGUgY29tbW9uOwogCV9fczMyIHBpcGVfb2JqcmVmOwpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9s
aW51eC9mdXNlLmggYi9pbmNsdWRlL2xpbnV4L2Z1c2UuaAppbmRleCAzZTI5MjVhLi4xMDRjNjdk
IDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L2Z1c2UuaAorKysgYi9pbmNsdWRlL2xpbnV4L2Z1
c2UuaApAQCAtMjQ5LDYgKzI0OSwxMCBAQCBlbnVtIGZ1c2Vfb3Bjb2RlIHsKIAlGVVNFX0lPQ1RM
ICAgICAgICAgPSAzOSwKIAlGVVNFX1BPTEwgICAgICAgICAgPSA0MCwKIAorI2lmZGVmIENPTkZJ
R19DSEVDS1BPSU5UCisJRlVTRV9DSEVDS1BPSU5UICAgID0gMTAyNCwKKyNlbmRpZiAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAvKkNPTkZJR19DSEVDS1BPSU5UKi8KKwkKIAkvKiBD
VVNFIHNwZWNpZmljIG9wZXJhdGlvbnMgKi8KIAlDVVNFX0lOSVQgICAgICAgICAgPSA0MDk2LAog
fTsKQEAgLTU2NSw0ICs1NjksMTYgQEAgc3RydWN0IGZ1c2Vfbm90aWZ5X2ludmFsX2VudHJ5X291
dCB7CiAJX191MzIJcGFkZGluZzsKIH07CiAKKyNpZmRlZiBDT05GSUdfQ0hFQ0tQT0lOVAorCXN0
cnVjdCBmdXNlX2NoZWNrcG9pbnRfaW57CisJX191NjQJZmg7CisJX191MzIJZmxhZ3M7CisJX191
MzIJcGFkZGluZzsKKyAgICAgICAgfTsKKworICAgICAgICBzdHJ1Y3QgZnVzZV9jaGVja3BvaW50
X291dHsKKyAgICAgICAgX191MzIgc3RhdHVzOworICAgICAgICB9OworI2VuZGlmICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAvKkNPTkZJR19DSEVDS1BP
SU5UKi8KKwogI2VuZGlmIC8qIF9MSU5VWF9GVVNFX0ggKi8K
--e0cb4e8873eb5db8eb049ffd3bd8
Content-Type: text/x-csrc; charset=US-ASCII; name="fuse_kcr.c"
Content-Disposition: attachment; filename="fuse_kcr.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gm0u5lxh1

LyoKZnVzZV9jcjogQ2hlY2twb2ludC1SZXN0YXJ0IGltcGxlbWVudGF0aW9uIGZvciBGVVNFIGZp
bGVzeXN0ZW0ga2VybmVsIG1vZHVsZS4KCkF1dGhvcnM6IE1hbm9qIEt1bWFyIGFuZCBWaXNobnVt
dXJ0aHkgUHJhYmh1IAogICAgICAgICBOSVRLIFN1cmF0aGthbAoqLwoKI2luY2x1ZGUgPGxpbnV4
L2ZpbGUuaD4KI2luY2x1ZGUgImZ1c2Vfa2NyLmgiCgppbnQgZnVzZV9maWxlX2NrcHRfc2VuZChz
dHJ1Y3QgZmlsZSAqZmlsZSkKewogICAgc3RydWN0IGlub2RlICppbm9kZSAgPSBmaWxlLT5mX3Bh
dGguZGVudHJ5LT5kX2lub2RlOwoJc3RydWN0IGZ1c2VfY29ubiAqZmMgPSBnZXRfZnVzZV9jb25u
KGlub2RlKTsKCXN0cnVjdCBmdXNlX3JlcSAqcmVxOwoJc3RydWN0IGZ1c2VfY2hlY2twb2ludF9p
biBpbmFyZzsKCXN0cnVjdCBmdXNlX2NoZWNrcG9pbnRfb3V0IG91dGFyZzsKCV9fdTY0IG5vZGVp
ZDsKCWludCBlcnI7CglzdHJ1Y3QgZnVzZV9maWxlICpmZjsKCiAgICBmZiA9IGZpbGUtPnByaXZh
dGVfZGF0YTsKCWlmIChpc19iYWRfaW5vZGUoaW5vZGUpKQoJCXJldHVybiAtRUlPOwoKICAgIG5v
ZGVpZCA9IGdldF9ub2RlX2lkKGlub2RlKTsKCXJlcSA9IGZ1c2VfZ2V0X3JlcShmYyk7CgltZW1z
ZXQoJmluYXJnLCAwLCBzaXplb2YoaW5hcmcpKTsKLy8gaW5hcmdzIG11c3QgYmUgc3VwcGxpZWQu
CQogICAgaW5hcmcuZmggPSBmZi0+Zmg7CiAgICBpbmFyZy5mbGFncyAmPSB+KDApOwovL2luYXJn
cyB0byBiZSBzdXBwbGllZCAgICAKICAgIAogICAgcmVxLT5pbi5oLm9wY29kZSA9IEZVU0VfQ0hF
Q0tQT0lOVDsKCXJlcS0+aW4uaC5ub2RlaWQgPSBub2RlaWQ7CglyZXEtPmluLm51bWFyZ3MgPSAx
OwoJcmVxLT5pbi5hcmdzWzBdLnNpemUgPSBzaXplb2YoaW5hcmcpOwoJcmVxLT5pbi5hcmdzWzBd
LnZhbHVlID0gJmluYXJnOwoJcmVxLT5vdXQubnVtYXJncyA9IDE7CglyZXEtPm91dC5hcmdzWzBd
LnNpemUgPSBzaXplb2Yob3V0YXJnKTsKCXJlcS0+b3V0LmFyZ3NbMF0udmFsdWUgPSAmb3V0YXJn
OwoKLy9hYm91ZSBpcyBzYW1wbGUgaW5hcmdzIG5lZWQgdG8gYmUgY2hhbmdlZC4uLgoJZnVzZV9y
ZXF1ZXN0X3NlbmQoZmMsIHJlcSk7CgllcnIgPSByZXEtPm91dC5oLmVycm9yOwoJZnVzZV9wdXRf
cmVxdWVzdChmYywgcmVxKTsKCWlmIChlcnIgPT0gLUVOT1NZUykgewoJCWZjLT5ub19mbHVzaCA9
IDE7CgkJZXJyID0gMDsKCX0KCXJldHVybiBvdXRhcmcuc3RhdHVzOwp9CgppbnQgZnVzZV9maWxl
X2NoZWNrcG9pbnQoc3RydWN0IGNrcHRfY3R4ICpjdHgsIHN0cnVjdCBmaWxlICpmaWxlKQp7CiAg
IGludCByZXQ7CiAgIHN0cnVjdCBja3B0X2hkcl9maWxlX2Z1c2UgKmg7CiAgIAoJaWYgKGRfdW5s
aW5rZWQoZmlsZS0+Zl9kZW50cnkpKSB7CgkJY2twdF9lcnIoY3R4LCAtRUJBREYsICIlKFQpJShQ
KVVubGlua2VkIGZpbGVzIHVuc3VwcG9ydGVkXG4iLAoJCQkgZmlsZSk7CgkJcmV0dXJuIC1FQkFE
RjsKCX0KCgloID0gY2twdF9oZHJfZ2V0X3R5cGUoY3R4LCBzaXplb2YoKmgpLCBDS1BUX0hEUl9G
SUxFKTsKCWlmICghaCkKCQlyZXR1cm4gLUVOT01FTTsKCgloLT5jb21tb24uZl90eXBlID0gQ0tQ
VF9GSUxFX0ZVU0U7ICAgCiAgIAoJcmV0ID0gY2hlY2twb2ludF9maWxlX2NvbW1vbihjdHgsIGZp
bGUsICZoLT5jb21tb24pOwoJaWYgKHJldCA8IDApCgkJZ290byBvdXQ7CglyZXQgPSBja3B0X3dy
aXRlX29iaihjdHgsICZoLT5jb21tb24uaCk7CglpZiAocmV0IDwgMCkKCQlnb3RvIG91dDsKCXJl
dCA9IGNoZWNrcG9pbnRfZm5hbWUoY3R4LCAmZmlsZS0+Zl9wYXRoLCAmY3R4LT5yb290X2ZzX3Bh
dGgpOwoJICAgCi8vICAgcmV0ID0gZnVzZV9maWxlX2NrcHRfc2VuZChmaWxlKTsKICAgIG91dDoK
CSAgY2twdF9oZHJfcHV0KGN0eCwgaCk7CgkgIHJldHVybiByZXQ7CQoKfQpFWFBPUlRfU1lNQk9M
KGZ1c2VfZmlsZV9jaGVja3BvaW50KTsKCi8qKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioKUmVzdGFydAoqLwoKc3RydWN0IGZpbGUgKmZ1c2VfZmlsZV9yZXN0b3JlKHN0cnVjdCBj
a3B0X2N0eCAqY3R4LCBzdHJ1Y3QgY2twdF9oZHJfZmlsZSAqcHRyKQp7CiAgICBzdHJ1Y3QgZmls
ZSAqZmlsZTsKCWludCByZXQ7CgoJaWYgKHB0ci0+aC50eXBlICE9IENLUFRfSERSX0ZJTEUgIHx8
CgkgICAgcHRyLT5oLmxlbiAhPSBzaXplb2YoKnB0cikgfHwgcHRyLT5mX3R5cGUgIT0gQ0tQVF9G
SUxFX0ZVU0UpCgkJcmV0dXJuIEVSUl9QVFIoLUVJTlZBTCk7CgoJZmlsZSA9IHJlc3RvcmVfb3Bl
bl9mbmFtZShjdHgsIHB0ci0+Zl9mbGFncyk7CglpZiAoSVNfRVJSKGZpbGUpKQoJCXJldHVybiBm
aWxlOwoKCXJldCA9IHJlc3RvcmVfZmlsZV9jb21tb24oY3R4LCBmaWxlLCBwdHIpOwoJaWYgKHJl
dCA8IDApIHsKCQlmcHV0KGZpbGUpOwoJCWZpbGUgPSBFUlJfUFRSKHJldCk7Cgl9CglyZXR1cm4g
ZmlsZTsKfQoK
--e0cb4e8873eb5db8eb049ffd3bd8
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--e0cb4e8873eb5db8eb049ffd3bd8--
