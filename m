From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/20] Introduce MS_KERNMOUNT flag
Date: Mon, 13 Aug 2007 11:12:06 +0400
Message-ID: <46C00446.7030703@openvz.org>
References: <46BC506B.mailGIV1AXDXM@openvz.org>
	<20070811034721.GB22216@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070811034721.GB22216-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
List-Id: containers.vger.kernel.org

Christoph Hellwig wrote:
> On Fri, Aug 10, 2007 at 03:47:55PM +0400, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org wrote:
>> This flag tells the .get_sb callback that this is a kern_mount() call
>> so that it can trust *data pointer to be valid in-kernel one. If this
>> flag is passed from the user process, it is cleared since the *data
>> pointer is not a valid kernel object.
>>
>> Running a few steps forward - this will be needed for proc to create the
>> superblock and store a valid pid namespace on it during the namespace
>> creation. The reason, why the namespace cannot live without proc mount
>> is described in the appropriate patch.
> 
> I don't like this at all.  We should never pass kernel and userspace
> addresses through the same pointer.  Maybe add an additional argument
> to the get_sb prototype instead.  But this whole idea of mounting /proc
> from kernelspace sounds like a really bad idea to me.  /proc should
> never be mounted from the kernel but always normally from userspace.

Why then is it mounted in proc_root_init()?

Thanks,
Pavel
