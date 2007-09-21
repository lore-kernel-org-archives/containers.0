From: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006-hi6Y0CQ0nG0@public.gmane.org>
Subject: Re: Kernel text size with pid namespace
Date: Fri, 21 Sep 2007 13:31:54 +0200
Message-ID: <46F3ABAA.6030607@gmx.net>
References: <20070920001644.GA14880@us.ibm.com> <46F239B2.8080500@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46F239B2.8080500-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On 20.09.2007 11:13, Pavel Emelyanov wrote:
> sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
>>
>> The pid-namespace patcheset (http://lkml.org/lkml/2007/8/10/118)
>> was added to the -mm tree in 2.6.23-rc3-mm1.
>>
>> With CONFIG_CC_OPTIMIZE_FOR_SIZE=y this patchset increases the kernel
>> text size by about 5K (closer to 6K when the config token is set to N).
> 
> Well, this is a new functionality, so the vmlinux size has to increase.
> And as Matt has noticed 5k is not that bad :)

Speaking with my LinuxBIOS hat on, even 1kB more can be the critical
code portion which causes the Linux kernel not to fit onto a BIOS ROM
chip any more. We already optimize for size and use LZMA compression to
fit a kernel onto an 1MB chip.

>> We also do not have a config token to select pid namespace (its always
>> enabled). 
> 
> This was one of Andrew's requirements. However, I assume that we can
> have the cloning code under this option.

If all new code which increases text size can be disabled via config
options, I'm happy. However, I fear that some size increase will be
unavoidable even with the config token disabled. As long as that doesn't
end up being more than 0.5kB or at maximum 1kB, it will be probably OK.

Thanks for taking size issues into consideration!

Regards,
Carl-Daniel
