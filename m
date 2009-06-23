From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 1/1] cr: lsm: restore LSM contexts for ipc objects
Date: Mon, 22 Jun 2009 20:10:33 -0700
Message-ID: <4A4047A9.8020202@schaufler-ca.com>
References: <20090620013216.GA4435@us.ibm.com>	 <1245682025.3033.178.camel@localhost.localdomain>	 <20090622175003.GA2416@us.ibm.com> <1245695023.12493.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1245695023.12493.7.camel@localhost.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
To: Stephen Smalley <sds@epoch.ncsc.mil>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

Stephen Smalley wrote:
> On Mon, 2009-06-22 at 12:50 -0500, Serge E. Hallyn wrote:
>   
>> Quoting Stephen Smalley (sds@epoch.ncsc.mil):
>>     
>>> Not sure you need to cache them in the cr layer (vs. just using the
>>> mapping functions provided by the LSM hook interface, and letting the
>>> security module handle caching internally).
>>>       
>> Do I understand correctly that secids are supposed to be consistent
>> across machines and reboots, but not across policy versions?
>>     
>
> No, secids are temporal - they are dynamically allocated at runtime like
> file descriptors.  You should only store security contexts in the
> images.
>   

Like he said. Smack would be happier if secid's went away, but
there's too much left over from the era when SELinux was the only
LSM for that to happen without crying and gnashing of teeth. A
secid is good only for the current invocation of the current
instance of the kernel.
