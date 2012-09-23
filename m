From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/4] devpts: fix devpts mount behavior
Date: Sun, 23 Sep 2012 10:42:32 -0700
Message-ID: <87txuo3abb.fsf@xmission.com>
References: <20120124000517.GA28878@sergelap>
	<CA+55aFz9ofF+Ey8VCDS8UEf2XSw36kj2RhkHfFScuzLXMeNrkA@mail.gmail.com>
	<20120124002555.GA29534@sergelap>
	<CA+55aFzwOU137V6wtyBjessx05NJo2G4KV0rvTKWvC79A+o9iQ@mail.gmail.com>
	<20120124010758.GJ23916@ZenIV.linux.org.uk>
	<m1k44gj1cu.fsf@fess.ebiederm.org> <20120124220247.GA26353@hallyn.com>
	<CAPXgP13_gczQmG_USAp0p2AuTfxkzAvzHvjbZY_rbbLH-4rDyg@mail.gmail.com>
	<20120124231601.GA4470@sergelap>
	<CAPXgP12REAwmDORzdGJhsxZKU8nhiauCxoVdKa8Eifw4MWWtgA@mail.gmail.com>
	<20120128195103.GA11299@sergelap> <87txup763i.fsf_-_@xmission.com>
	<505F3D48.7080103@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <505F3D48.7080103-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org> (H. Peter Anvin's message of "Sun,
	23 Sep 2012 09:48:08 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org> writes:

> On 09/22/2012 08:47 PM, Eric W. Biederman wrote:
>> Making /dev/ptmx a symlink sounds simple, but in practice no one could
>> actually figure out how to make it happen.
>
> This feels particularly ridiculous since udev now requires devtmpfs
> (as in it will no longer work without it), which means this is all
> done in the kernel, so we should just be able to fix this in the
> kernel.

Some versions of udev require devtmpfs.  At best we could have something
conditional in the kernel that does this.

> Greg, Kay, any idea how to make ptmx show up in devtmpfs as a symlink
> to pts/pmtx instead of as a device node?

The conversation stalled in January with that very question.

What I am proposing doesn't conflict with any effort like that.

Eric
