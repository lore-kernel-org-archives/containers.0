From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: selinux mini-summit sub-policy topic
Date: Thu, 17 Apr 2008 12:55:30 -0500
Message-ID: <20080417175530.GA21302@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: fmac-discuss-xZgeD5Kw2fzokhkdeNNY6A@public.gmane.org, fedora-selinux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, SELinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

It appears many of us have a related policy issue.

The Fedora folks want to be able to create distro images under a chroot
or namespace with selinux enforcing, but with the distro images having
different policy from the host.  I don't know whether they want to be
able to run tests under that image, or only be able to write down
potentially unknown labels so as to be able to lay the image down on
disk.

The fmac (opensolaris) folks may want to be able to load different
policies in different zones.

The linux containers folks (and I) want basically the same thing as
zones folks, that, is to support container administrators loading their
own policy.  My plan had been to pull together what I can to propose a
LISA paper, so I was hoping to really get geared up this week after
finishing other papers.  (This is free time stuff, and has been on
the back burner for a year now.)  In the containers case, I am
starting to use the type namespace (container1.subtype1) to confine
a container policy, where subtype1 in container1 is known to the
host as container1.subtype1.  This leaves MLS and MCS unsupported ATM.

Dan Walsh is working policy for xen/qemu images, however that is
not really related as the vm has its own OS.  I'm mentioning it here
in case I'm wrong.

Are there other projects needing similar support?  There used to be
a problem with rpms being able to create files with not-yet-defined
types, which may be more similar to the fedora problem above, and I
have no idea whether/how that ended up being resolved.

Is it worth proposing a joint topic for discussion at the selinux
mini-summit?  It could take several formats, from a meeting amongst
ourselves followd by a panel discussion, to a set of lightning talks, to
a 30 minute joint presentation where we present what we talk about in
emails before OLS.

thanks,
-serge
