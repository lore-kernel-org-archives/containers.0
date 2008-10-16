From: "Alexey Eremenko" <al4321-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: lxc userspace tools 0.3.0 released
Date: Thu, 16 Oct 2008 09:56:54 +0000
Message-ID: <7fac565a0810160256mc3de8b5raf4bab31470b051a@mail.gmail.com>
References: <48F4AF2E.3000204@fr.ibm.com>
	<7fac565a0810160122n7afa6e71l929be8cb08ba05c6@mail.gmail.com>
	<48F70E53.9070002@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48F70E53.9070002-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Well, Thanks for explanation...

libvirt uses liblxc or uses kernelspace containers directly ?

>> 2. What portion of code is shared between the two ?
>
> I am not sure I understand the question. Do you mean : "is liblxc using
> OpenVZ code ?"
>

Here I mean that OpenVZ and LXC have kernelspace code shared - at
least partially.
(because OpenVZ developers are the ones who are developing kernelspace
LXC and pushing code upstream)

Do you know how much of it ?

I think userspace is not shared at all.

-- 
-Alexey Eromenko "Technologov"
