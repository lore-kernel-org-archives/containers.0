From: Tejun Heo <teheo@suse.de>
Subject: Re: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Thu, 09 Aug 2007 00:16:46 +0900
Message-ID: <46B9DE5E.7050406@suse.de>
References: <11860582832964-git-send-email-htejun@gmail.com>	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>	<20070808093815.0935a18e@gondolin.boeblingen.de.ibm.com>	<m1bqdifowo.fsf@ebiederm.dsl.xmission.com>	<20070808095432.4a520735@gondolin.boeblingen.de.ibm.com>	<m17io6foh8.fsf@ebiederm.dsl.xmission.com>	<20070808103759.0850383c@gondolin.boeblingen.de.ibm.com>	<20070808161631.1ccf27fd@gondolin.boeblingen.de.ibm.com>	<46B9D4B8.4050201@gmail.com>	<20070808165027.29af40b5@gondolin.boeblingen.de.ibm.com>	<46B9D961.4000902@gmail.com> <m1r6medpxl.fsf@ebiederm.dsl.xmission.com> <46B9DDA1.1080704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934791AbXHHPRU@vger.kernel.org>
In-Reply-To: <46B9DDA1.1080704@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

Tejun Heo wrote:
> Eric W. Biederman wrote:
>> Tejun Heo <htejun@gmail.com> writes:
>>
>>> Cornelia Huck wrote:
>>>> On Wed, 08 Aug 2007 23:35:36 +0900,
>>>> Tejun Heo <htejun@gmail.com> wrote:
>>>>
>>>>> Does the attached patch happen to fix the problem?
>>>> Indeed it does; thanks!
>>> Yeah, you seem to have 32bit off_t.  UINT_MAX overflows, so...
>> Weird.  And we have it opening the directory O_LARGEFILE.
>>
>> I have no problems with the fix though.
> 
> It's probably because of struct dirent definition used by readdir().

More specifically, d_off field.  It's a bit twisted.  For the last
entry, filp->f_pos gets written into the field and gets wrapped while
being copied out to userland or in glibc.

-- 
tejun
