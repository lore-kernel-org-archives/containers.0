From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: Re: Using overlayfs in (unprivileged) namespace
Date: Mon, 15 Feb 2016 13:47:46 +0200
Message-ID: <56C1BAE2.30209@kyup.com>
References: <56C1B0C6.6080806@philippwendler.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <56C1B0C6.6080806-PRuqubkS1MrCxoAYUeDZubNAH6kLmebB@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Philipp Wendler <ml-PRuqubkS1MrCxoAYUeDZubNAH6kLmebB@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



On 02/15/2016 01:04 PM, Philipp Wendler wrote:
> Hello all,
> 
> I would like to mount an overlayfs inside unprivileged user and mount
> namespaces (i.e., the user creating the namespaces is a regular user
> with no special privileges).
> This works mostly fine, but it fails as soon as I try to delete a file
> which exists in the "lower" directory of the overlay,
> because overlayfs then needs to create a "whiteout" file,
> for which it uses a device node with 0/0 device number
> (https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt),
> but I do not have the permission to create device nodes.
> 
> Is there any way to make overlayfs work fully in my situation,
> without requiring additional privileges?
> If not, is this something that could be made work in the future?
> Of course, creating arbitrary devices nodes is something that cannot be
> granted to an unprivileged user, but in this case it is only a specific
> device node with device numbers 0/0, and it is a kernel module creating
> the device node on behalf of me.
> 
> I am currently using Linux 4.2. To reproduce the problem,
> you can use the following steps:
> Create the mount and user namespaces with the example program from the
> user_namespaces man page
> (http://man7.org/linux/man-pages/man7/user_namespaces.7.html),
> mapping the user root inside the namespace to my user:
> 
> $ ./userns_child_exec -m -U -z bash
> 
> Then execute the following commands:
> 
> mkdir /tmp/namespace-overlay
> cd /tmp/namespace-overlay
> mkdir mount lower upper work
> touch lower/test
> mount -t overlayfs n -o lowerdir=lower,upperdir=upper,workdir=work mount
> rm mount/test
> 
> The last command gives:
>> rm: cannot remove 'mount/test': Operation not permitted
> 
> This fails even if /tmp does not have "nodev" set (with "nodev" it would
> be expected to fail of course).
> Interestingly, it even fails if I start userns_child_exec as root,
> not sure why.
> Outside namespaces everything works as expected.

Wouldn't using the device cgroup with the respective major/minor numbers
allowed rectify the situation? Also, have you done any tracing trying to
figure out where exactly is this failing? E.g. using ftrace?


> 
> Kind regards,
> Philipp
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
> 
