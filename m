From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 1/2] nfnetlink: add netns support
Date: Wed, 13 Jan 2010 14:42:00 +0100
Message-ID: <4B4DCDA8.5070108__42560.5366508991$1263390178$gmane$org@trash.net>
References: <20100113122420.GA5790@x200> <4B4DC469.5000408@trash.net>
	<20100113132255.GA16975@x200> <4B4DCA2C.7020000@trash.net>
	<20100113133727.GC16975@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100113133727.GC16975@x200>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> On Wed, Jan 13, 2010 at 02:27:08PM +0100, Patrick McHardy wrote:
>> Alexey Dobriyan wrote:
>>> On Wed, Jan 13, 2010 at 02:02:33PM +0100, Patrick McHardy wrote:
>>>> Alexey Dobriyan wrote:
>>>>> +	struct sock		*nfnl;
>>>>> +	struct sock		*nfnl_stash;
>>>> Shouldn't this be contained in an ifdef(CONFIG_NETFILTER_NETLINK)
>>>> (_MODULE) ?
>>> No, otherwise you won't be able to start using, e. g., nfnetlink_log
>>> module on NETFILTER_NETLINK=n kernels without reboot.
>> You mean after enabling CONFIG_NETFILTER_NETLINK?
> 
> Yes, and it can't be directly enabled, because it's hidden option.
> 
>> That seems like a pretty poor argument, you have to do a reboot after
>> changing a lot of config options.
> 
> It's still a step back if I add #ifdef and a regression if you ask me.
> The price is only two pointers per-netns.

Yes, I don't mind much, but I still think this is not an argument
at all. Whether you have to reboot after changing your configuration
has never been "stable" and we don't consider it when making changes.
