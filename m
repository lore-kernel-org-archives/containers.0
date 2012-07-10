From: Jay Vosburgh <fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] bonding: debugfs and network namespaces are
	incompatible
Date: Tue, 10 Jul 2012 10:36:12 -0700
Message-ID: <15459.1341941772__42512.2825349264$1341941868$gmane$org@death.nxdomain>
References: <20120706194741.GA22113@mail.hallyn.com>
	<87y5ms3bfi.fsf_-_@xmission.com> <87sjd03bdw.fsf_-_@xmission.com>
	<20120709.144932.243254122059983829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <20120709.144932.243254122059983829.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dilip.daya-VXdhtT5mjnY@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

>From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
>Date: Mon, 09 Jul 2012 13:52:43 -0700
>
>> 
>> The bonding debugfs support has been broken in the presence of network
>> namespaces since it has been added.  The debugfs support does not handle
>> multiple bonding devices with the same name in different network
>> namespaces.
>> 
>> I haven't had any bug reports, and I'm not interested in getting any.
>> Disable the debugfs support when network namespaces are enabled.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>
>Applied.

	Since distro kernels appear to set CONFIG_NET_NS, doesn't this
effectively disable debugfs for bonding on most distros?

	Do the other network device drivers that support debugfs have a
similar problem?  E.g., if each of two namespaces have an skge device
with the same name, will there be a debugfs conflict there as well?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
