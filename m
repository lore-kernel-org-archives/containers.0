From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: ns_can_attach (nsproxy cgroup)
Date: Fri, 19 Dec 2008 08:43:25 +0800
Message-ID: <494AEE2D.8020703@cn.fujitsu.com>
References: <20081212095153.GA20956@megiteam.pl>
	<20081212140908.GA9571@us.ibm.com>
	<20081212213042.GA23581@megiteam.pl>
	<49435E58.9050209@cn.fujitsu.com>
	<20081214140604.GA22768@megiteam.pl>
	<20081216230808.GA26026@megiteam.pl>
	<49484D33.5020308@cn.fujitsu.com>
	<20081218144506.GA2185@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081218144506.GA2185-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

>> Now looks good to me. :)
>>
>> Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> 
> Thanks, shall I send the patch somewhere else for some mainstream tree
> inclusion or is somebody willing to pick it up from here?
> 

You can resend this patch to Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
and CC Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> since the patch touches cgroup.c,
and feel free to add my reviewed tag. :)

> Best regards,
>  Grzegorz Nosek
> 
> 
