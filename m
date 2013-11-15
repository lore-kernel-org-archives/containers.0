From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: Getting userns enabled in vendor kernels
Date: Fri, 15 Nov 2013 13:19:45 +0800
Message-ID: <5285AEF1.6000503@cn.fujitsu.com>
References: <20131113151330.GZ32643@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131113151330.GZ32643-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 11/13/2013 11:13 PM, Daniel P. Berrange wrote:
> The user namespace work gave us two new features
> 
>  - Ability to set UID/GID mappings between containers & host
>  - Ability for unprivileged users to create namespaces
> 
> The first of these features is really critical to be able to make the
> use of LXC secure using DAC, rather than having to rely on the use of
> MAC (SELinux/AppArmour) protection.
> 
> The second feature is a nice, but it is not critical in the same way,
> since it is all about opening up new use cases, rather than securing
> existing use cases.
> 
> Both of these features are under the same CONFIG_USER_NS Kconfig setting,
> so you can't get the former without also getting the latter.
> 
> This is a problem because distro kernel maintainers are rejecting requests
> to enable CONFIG_USER_NS over concern that it significantly expands the
> attack surface accessible to unprivileged users. Fedora, RHEL & Arch Linux
> have all rejected enabling CONFIG_USER_NS as it is due to this concern.
> 
> This sucks, because there's a really pressing need to make the ID mapping
> feature available, while there isn't much sense of urgency over allowing
> unprivileged users to create namespaces.
> 
> In Fedora I managed to get agreement to enable CONFIG_USER_NS provided
> that the following patch is reverted [1]
> 
>   commit 5eaf563e53294d6696e651466697eb9d491f3946
>   Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>   Date:   Mon Nov 21 17:22:31 2011 -0800
> 
>     userns: Allow unprivileged users to create user namespaces.

I don't know what's the benefit this commit brings and what's use
case this commit tries to support.

In most use case, the container/namespace is create by privilged
user and the id-map can prevent unsafe things.

IMO, I think this patch can be reverted.

Thanks
