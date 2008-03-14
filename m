From: Stephen Smalley <sds-FVV4AS6k8l2W8mdqIt43Ew@public.gmane.org>
Subject: Re: [PATCH] cgroups: implement device whitelist lsm (v3)
Date: Fri, 14 Mar 2008 09:27:28 -0400
Message-ID: <1205501248.22912.35.camel@moss-spartans.epoch.ncsc.mil>
References: <20080313144142.GB11265@sergelap.austin.ibm.com>
	<Xine.LNX.4.64.0803142039460.32184@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Xine.LNX.4.64.0803142039460.32184-RC8Ws/H8zzudju81dFSl6rpzq4S04n8Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


On Fri, 2008-03-14 at 21:17 +1100, James Morris wrote:
> On Thu, 13 Mar 2008, Serge E. Hallyn wrote:
> 
> > Implement a cgroup using the LSM interface to enforce open and mknod
> > on device files.
> 
> Actually, I'm not sure that the LSM approach in general is best here.
> 
> The LSM model is that standard DAC logic lives in the core kernel, and 
> that extended security logic (e.g. MAC) is called after DAC via hooks.  
> cgroups has introduced new security logic of its own, which is arguably 
> "standard DAC" when cgroups is enabled.
> 
> I can understand Greg not wanting this security logic in the core kernel, 
> but it is specific to cgroups (which itself is security model agnostic) 
> and does not stand alone as a distinct security framework.
> 
> The fact that all existing LSMs need to invoke exactly the same code is an 
> indicator that it doesn't belong in LSM.
> 
> Moving this logic into LSM means that instead of the cgroups security 
> logic being called from one place in the main kernel (where cgroups 
> lives), it must be called identically from each LSM (none of which are 
> even aware of cgroups), which I think is pretty obviously the wrong 
> solution.
> 
> This is baggage which comes with cgroups -- please don't push it into LSM 
> to try and hide that.

I agree with the above, and would further note that I would expect the
SELinux solution to the problem would be done not by stacking with or
calling this device whitelist lsm but instead by introducing the ability
to bind security labels to devices within the kernel (independent of the
particular device node(s) in the filesystem used to access that device)
and applying permission checks on those device labels when processes
attempt to create or access those devices (again independent of the
particular device node used to access them).  That keeps the policy
integrated and analyzable and avoids an external dependency.

-- 
Stephen Smalley
National Security Agency
