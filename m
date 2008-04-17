From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH]: Factor out PTY index allocation
Date: Thu, 17 Apr 2008 12:05:36 -0400
Message-ID: <48077550.1080105@zytor.com>
References: <20080416221723.GB7112@us.ibm.com> <20080417154241.GC14215@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934489AbYDQQKo@vger.kernel.org>
In-Reply-To: <20080417154241.GC14215@sergelap.austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: sukadev@us.ibm.com, Andrew Morton <akpm@osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting sukadev@us.ibm.com (sukadev@us.ibm.com):
>> We noticed this while working on pts namespaces and believe this might
>> be an useful change even as we rework our pts/device namespace approach.
>>
>> ---
>>
>> From: Sukadev Bhattiprolu <sukadev@us.ibm.com>
>> Subject: [PATCH]: Factor out PTY index allocation
>>
>> Factor out the code used to allocate/free a pts index into new interfaces,
>> devpts_new_index() and devpts_kill_index().  This localizes the external
>> data structures used in managing the pts indices.
>>
>> Signed-off-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>
>> Signed-off-by: Serge Hallyn<serue@us.ibm.com>
>> Signed-off-by: Matt Helsley<matthltc@us.ibm.com>
> 
> No traces of devpts namespaces here, so I assume this should be
> non-offensive and fine for inclusion.
> 

Acked-by: H. Peter Anvin <hpa@zytor.com>
