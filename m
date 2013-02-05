From: Honghui Zhang <zhanghonghui-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: Regarding LXC and Libvirt integration state.
Date: Tue, 5 Feb 2013 17:34:13 +0800
Message-ID: <5110D215.9090101@huawei.com>
References: <CAF0SE4czOKVjB-0D461jZr1DoGyjbcCDCeNswqem6k0t9hkinA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAF0SE4czOKVjB-0D461jZr1DoGyjbcCDCeNswqem6k0t9hkinA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/2/5 17:21, Kunal Kushwaha wrote:
> Hi Daniel,
> 
> I am trying to create LXC containers on Centos 6.3. My libvirt version is
> libvirt-0.9.10-21.el6_3.8.x86_64.
> 
> I used your mail from
> http://lists.linux-foundation.org/pipermail/containers/2008-September/013237.html
> for creating LXC container.
> 
> I am facing following issues.
> 
> 1. If I use bridge network, from inside container, I am not able to access
> host network. Not even able to ping the br0 of host machine.

Do you have add the route in the container and configure you br0 ip addr in
the host?

> 2. Cannot ping the container from host machine.

Well, you could not get the reply from container unless you have add the route
in the container.

> 
> Also, It would be great help, if you can give some light on, how much
> libvirt supports LXC.
> - I tried to add network , Storage using virsh command, but it is not
> working.
> 
> If these are not supported, what is roadmap for these features?
> 
> Sorry for sounding demanding, but just want to understand the libvirt and
> LXC integration state.
> 
