From: Michal Privoznik <mprivozn-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [libvirt] necessary to limit container's network bandwidth when
	use physical nic in container?
Date: Mon, 15 Oct 2012 10:52:41 +0200
Message-ID: <507BCED9.1080003@redhat.com>
References: <507BC3E0.6070304@cn.fujitsu.com> <507BCAC3.4020609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <507BCAC3.4020609-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 15.10.2012 10:35, Gao feng wrote:
> we can use tc to limit container's network bandwidth when the container uses veth device.
> because one of the veth devices will be seen in the host.so we can set tc rules on this
> device on the host.
> 
> I want to know if it's necessary to limit container's network bandwidth when the container
> uses a physical nic device. because this nic device is only used by this container.
> 
> And if this is necessary,Be there any good idea?
> 
> Thanks!
> 

Well, that depends. If you expect you guest to consume all bandwidth
then you need to set a floor on root eth. Guest is then still able to
use the full bandwidth, however if there are some packets for the host
those get prioritized. In general, it's a good idea, but to tell for
sure one should learn more about your usage scenario.

Michal
